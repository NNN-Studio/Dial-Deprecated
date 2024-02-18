//
//  Device.swift
//  Dial
//
//  Created by KrLite on 2023/10/30.
//

import Foundation
import Defaults

protocol InputHandler {
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState)
    
    func onRotation(_ direction: Direction, _ buttonState: Device.ButtonState)
    
}

@Observable class Device {
    
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
    
    
    
    var connectionStatus: ConnectionStatus = .disconnected
    
    var inputHandler: InputHandler?
    
    var lastButtonState: ButtonState = .released
    
    private var dev: OpaquePointer?
    
    private let readBuffer = ReadBuffer(size: 1024)
    
    private var thread: Thread?
    
    private var isRunning: Bool = false
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    deinit {
        stop()
        hid_exit()
    }
    
}

extension Device {
    
    enum ConnectionStatus {
        
        case connected(String)
        
        case disconnected
        
        var isConnected: Bool {
            switch self {
            case .connected(_):
                true
            case .disconnected:
                false
            }
        }
        
    }
    
    enum HapticsMode: UInt8 {
        
        case none = 0x02
        
        case buzz = 0x03
        
        case continuous = 0x04
        
    }
    
    enum InputReport {
        
        case dial(ButtonState, Direction?)
        
        case unknown
        
    }
    
    enum ButtonState {
        
        case pressed
        
        case released
        
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
            connectionStatus = .connected(serialNumber)
            initSensitivity()
            buzz(3)
        }
        
        return isConnected
    }
    
    
    private func disconnect() {
        if let dev = self.dev {
            hid_close(dev)
            
            self.dev = nil
            connectionStatus = .disconnected
            print("Device disconnected.")
        }
    }
    
    // https://github.com/daniel5151/surface-dial-linux/blob/main/src/dial_device/haptics.rs
    private func initSensitivity() {
        if isConnected {
            let steps_lo = 360 & 0xff
            let steps_hi = (360 >> 8) & 0xff
            var buf: Array<UInt8> = []
            
            buf.append(0x01) // Report ID
            buf.append(UInt8(steps_lo))
            buf.append(UInt8(steps_hi))
            buf.append(0x00) // Repeat count
            
            buf.append(0x02) // Do not auto trigger haptics
            
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
        
        if Defaults[.hapticsEnabled] && isConnected {
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
        _ bytes: UnsafeMutableBufferPointer<UInt8>
    ) -> InputReport {
        switch bytes[0] {
        case 0x01 where bytes.count >= 4:
            let buttonState = bytes[1] & 0x01 == 0x01 ? ButtonState.pressed : .released
            let hasRotation = bytes[2] != 0x00
            var direction: Direction?
            
            if hasRotation {
                direction = switch bytes[3] {
                case 0x00:
                    .clockwise
                case 0xff:
                    .counterclockwise
                default:
                    nil
                }
            }
            
            return .dial(buttonState, direction?.multiply(Defaults[.direction]))
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
        print("Reading data from device: \(dataStr)", terminator: "")
        
        let result = parse(array)
        switch result {
        case .unknown:
            print(" (unknown)")
        default:
            print()
        }
        return result
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
                case .dial(let buttonState, let direction):
                    switch buttonState {
                    case .pressed where lastButtonState == .released:
                        inputHandler?.onButtonStateChanged(.pressed)
                    case .released where lastButtonState == .pressed:
                        inputHandler?.onButtonStateChanged(.released)
                    default:
                        break
                    }
                    
                    if let direction {
                        inputHandler?.onRotation(direction, buttonState)
                    }
                    
                    self.lastButtonState = buttonState
                default:
                    break
                }
            }
            
            print("Waiting for 60 seconds before next try.")
            let _ = semaphore.wait(timeout: .now().advanced(by: .seconds(60)))
        }
    }
    
}

extension Device {
    
    var callback: Callback {
        Callback(self)
    }
    
    struct Callback {
        
        private var device: Device
        
        init(
            _ device: Device
        ) {
            self.device = device
        }
        
        func buzz(_ repeatCount: UInt8 = 1) {
            device.buzz(repeatCount)
        }
        
    }
    
}
