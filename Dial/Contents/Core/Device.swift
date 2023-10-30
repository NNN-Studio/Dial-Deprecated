//
//  Device.swift
//  Dial
//
//  Created by KrLite on 2023/10/30.
//

import Foundation

extension NSString {
    
    convenience init(wcharArray: UnsafeMutablePointer<wchar_t>) {
        self.init(
            bytes: UnsafePointer(wcharArray),
            length: wcslen(wcharArray) * MemoryLayout<wchar_t>.stride,
            encoding: String.Encoding.utf32LittleEndian.rawValue
        )!
    }
    
}

protocol DeviceEventHandler {
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?)
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState)
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState)
    
}

class Device {
    
    private struct ReadBuffer {
        let pointer: UnsafeMutablePointer<UInt8>
        let size: Int
        init(size: Int) {
            self.size = size
            pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        }
    }
    
    
    
    // Product identifiers for Surface Dials
    
    static let vendorId: UInt16 = 0x045E
    
    static let productId: UInt16 = 0x091B
    
    
    
    private var dev: OpaquePointer?
    
    private let readBuffer = ReadBuffer(size: 1024)
    
    private var thread: Thread?
    
    private var isRunning: Bool = false
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var lastButtonState = ButtonState.released
    
    
    
    var eventHandler: DeviceEventHandler?
    
    init(
        eventHandler: DeviceEventHandler? = nil
    ) {
        self.eventHandler = eventHandler
        hid_init()
    }
    
    deinit {
        stop()
        hid_exit()
    }
    
}

extension Device {
    
    enum HapticsMode: UInt8 {
        
        case none = 0x02
        
        case buzz = 0x03
        
        case continuous = 0x04
        
    }
    
    enum InputReport {
        
        case dial(ButtonState, Rotation?)
        
        case unknown
        
    }
    
    enum ButtonState {
        
        case pressed
        
        case released
        
    }
    
    enum Rotation {
        
        case clockwise(Int)
        
        case counterclockwise(Int)
        
        
        
        var magnitude: Int {
            switch self {
            case .clockwise(let r), .counterclockwise(let r):
                abs(r)
            }
        }
        
        var negate: Rotation {
            switch self {
            case .clockwise(let r):
                    .counterclockwise(r)
            case .counterclockwise(let r):
                    .clockwise(r)
            }
        }
        
        var direction: Direction {
            switch self {
            case .clockwise(_):
                    .clockwise
            case .counterclockwise(_):
                    .counterclockwise
            }
        }
        
        func byDirection(_ direction: Direction) -> Rotation {
            return direction == .counterclockwise ? negate : self
        }
        
    }
    
}

extension Device {
    
    var isConnected: Bool {
        dev != nil
    }
    
    var manufacturer: String {
        get {
            guard let dev = self.dev else {
                return ""
            }
            
            let buffer = UnsafeMutablePointer<wchar_t>.allocate(capacity: 255)
            
            hid_get_manufacturer_string(dev, buffer, 255)
            
            return NSString(wcharArray: buffer) as String
        }
    }
    
    var serialNumber: String {
        get {
            guard let dev = self.dev else {
                return ""
            }
            
            let buffer = UnsafeMutablePointer<wchar_t>.allocate(capacity: 255)
            hid_get_serial_number_string(dev, buffer, 255)
            
            return NSString(wcharArray: buffer) as String
        }
    }
    
    @discardableResult
    private func connect() -> Bool {
        dev = hid_open(Device.vendorId, Device.productId, nil)
        
        if isConnected {
            print("Connected to device \(serialNumber)!")
            eventHandler?.onConnectionStatusChanged(true, serialNumber)
            buzz(3)
        }
        
        return isConnected
    }
    
    
    private func disconnect() {
        if let dev = self.dev {
            hid_close(dev)
            
            self.dev = nil
            eventHandler?.onConnectionStatusChanged(false, nil)
            print("Device disconnected.")
        }
    }
    
    // https://github.com/daniel5151/surface-dial-linux/blob/main/src/dial_device/haptics.rs
    func updateHaptics(
        _ flag: Bool = Data.haptics
    ) {
        if isConnected {
            let steps_lo = 3600 & 0xff
            let steps_hi = (3600 >> 8) & 0xff
            var buf: Array<UInt8> = []
            
            buf.append(0x01) // Report ID
            buf.append(UInt8(steps_lo)) // Steps
            buf.append(UInt8(steps_hi)) // Steps
            buf.append(0x00) // Repeat count
            
            buf.append(flag ? HapticsMode.continuous.rawValue : 0x02) // Auto trigger every 1/3600 turn
            
            buf.append(0x00) // Waveform cutoff time
            buf.append(0x00) // Retrigger period (lo)
            buf.append(0x00) // Retrigger period (hi)
            
            hid_send_feature_report(dev, buf, 8)
        }
    }
    
    func buzz(
        _ repeatCount: UInt8 = 1
    ) {
        guard repeatCount > 0 else { return }
        
        if isConnected {
            var buf: Array<UInt8> = []
            
            buf.append(0x01) // Report ID
            buf.append(repeatCount - 1) // Repeat count
            
            buf.append(HapticsMode.buzz.rawValue) // Buzz
            
            buf.append(0x00) // Retrigger period (lo)
            buf.append(0x00) // Retrigger period (hi)
            
            hid_write(dev, buf, 5)
        }
    }
    
    private func parse(
        bytes: UnsafeMutableBufferPointer<UInt8>
    ) -> InputReport {
        switch bytes[0] {
        case 1 where bytes.count >= 4:
            let buttonState = bytes[1]&1 == 1 ? ButtonState.pressed : .released
            
            let rotation = { () -> Rotation? in
                switch bytes[2] {
                case 1:
                    return .clockwise(1)
                case 0xff:
                    return .counterclockwise(1)
                default:
                    return nil
                }}()
            
            return .dial(buttonState, rotation)
        default:
            return .unknown
        }
    }
    
    func read() -> InputReport? {
        guard let dev = self.dev else { return nil }
        
        let readBytes = hid_read(dev, readBuffer.pointer, readBuffer.size)
        
        if readBytes <= 0 {
            disconnect()
            return nil
        }
        
        let array = UnsafeMutableBufferPointer(start: readBuffer.pointer, count: Int(readBytes))
        
        let dataStr = array.map({ String(format:"%02X", $0)}).joined(separator: " ")
        print("Reading data from device: \(dataStr)")
        
        return parse(bytes: array)
    }
    
}

extension Device {
    
    func start() {
        self.thread = Thread(
            target: self,
            selector: #selector(threadProc(_:)),
            object: nil
        );
        
        isRunning = true;
        thread!.start()
    }
    
    func stop() {
        isRunning = false
        
        if let thread {
            semaphore.signal()
            disconnect()
            
            while !thread.isFinished {}
            self.thread = nil
        }
    }
    
    @objc
    private func threadProc(_ arg: NSObject) {
        while isRunning {
            if !isConnected {
                print("Connecting to device...")
                
                if !connect() {
                    print("Connection failed.")
                }
            }
            
            while isConnected {
                switch read() {
                case .dial(let buttonState, let rotation):
                    switch buttonState {
                    case .pressed where lastButtonState == .released:
                        eventHandler?.onButtonStateChanged(.pressed)
                    case .released where lastButtonState == .pressed:
                        eventHandler?.onButtonStateChanged(.released)
                    default: break
                    }
                    
                    if let rotation {
                        eventHandler?.onRotation(rotation.byDirection(Data.direction), buttonState)
                    }
                    
                    self.lastButtonState = buttonState
                case .unknown:
                    print("Unknown input report.")
                default:
                    break
                }
            }
            
            print("Waiting for 60 seconds before next try.")
            let _ = semaphore.wait(timeout: .now().advanced(by: .seconds(60)))
        }
    }
    
}
