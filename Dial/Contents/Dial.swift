
import Foundation
import AppKit
import Cocoa
import SwiftUI

extension NSString {
    
    convenience init(wcharArray: UnsafeMutablePointer<wchar_t>) {
        self.init(
            bytes: UnsafePointer(wcharArray),
            length: wcslen(wcharArray) * MemoryLayout<wchar_t>.stride,
            encoding: String.Encoding.utf32LittleEndian.rawValue
        )!
    }
    
}

class Dial {
    
    enum ButtonState {
        
        case pressed
        
        case released
        
    }
    
    enum Rotation {
        
        case clockwise(Int)
        
        case counterclockwise(Int)
        
        var magnitude: Int {
            switch self {
            case .clockwise(let r):
                r
            case .counterclockwise(let r):
                r
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
        
        func withDirection(_ direction: Direction) -> Rotation {
            var reversed = false
            switch self {
            case .clockwise(_) where direction == .clockwise:
                reversed = true
                break
            case .counterclockwise(_) where direction == .counterclockwise:
                reversed = false
                break
            default:
                break
            }
            return reversed ? negate : self
        }
        
    }
    
    enum InputReport {
        
        case dial(ButtonState, Rotation?)
        
        case unknown
        
    }
    
    enum HapticsMode: UInt8 {
        
        case none = 0x02
        
        case buzz = 0x03
        
        case continuous = 0x04
        
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
        
        // Identifiers for the Surface Dial
        static let VendorId: UInt16 = 0x045E
        static let ProductId: UInt16 = 0x091B
        
        private var dev: OpaquePointer?
        private let readBuffer = ReadBuffer(size: 1024)
        
        
        
        var hapticsMode = { HapticsMode.buzz }
        
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
        func connect() -> Bool {
            dev = hid_open(Dial.Device.VendorId, Dial.Device.ProductId, nil)
            return isConnected
        }
        
        
        func disconnect() {
            if let dev = self.dev {
                hid_close(dev)
            }
            
            dev = nil
        }
        
        // https://github.com/daniel5151/surface-dial-linux/blob/main/src/dial_device/haptics.rs
        func updateSensitivity(sensitivity: Sensitivity = Data.sensitivity, haptics: Bool = Data.haptics) {
            if isConnected {
                let steps_lo = sensitivity.rawValue & 0xff;
                let steps_hi = (sensitivity.rawValue >> 8) & 0xff;
                var buf: Array<UInt8> = []
                
                buf.append(0x01) // Report ID
                buf.append(UInt8(steps_lo)) // Steps
                buf.append(UInt8(steps_hi)) // Steps
                buf.append(0x00) // Repeat count
                
                // 0x02: none
                // 0x03: buzz
                // 0x04: continuous vibration
                buf.append(haptics ? hapticsMode().rawValue : 0x02) // Auto trigger
                
                buf.append(0x00) // Waveform cutoff time
                buf.append(0x00) // Retrigger period (lo)
                buf.append(0x00) // Retrigger period (hi)
                
                hid_send_feature_report(dev, buf, 8)
            }
        }
        
        func buzz(_ repeatCount: UInt8 = 1) {
            if repeatCount <= 0 {
                return
            }
            
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
        
        private func parse(bytes: UnsafeMutableBufferPointer<UInt8>) -> InputReport {
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
        
        func read() -> InputReport?
        {
            guard let dev = self.dev else { return nil }
            
            let readBytes = hid_read(dev, readBuffer.pointer, readBuffer.size)
            
            if readBytes <= 0 {
                self.dev = nil;
                return nil;
            }
            
            let array = UnsafeMutableBufferPointer(start: readBuffer.pointer, count: Int(readBytes))
            
            let dataStr = array.map({ String(format:"%02X", $0)}).joined(separator: " ")
            print("Read data from device: \(dataStr)")
            
            return parse(bytes: array)
        }
        
    }
    
    private var thread: Thread?
    private var run: Bool = false
    
    let device = Device()
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var lastButtonState = ButtonState.released
    
    var onButtonStateChanged: ((ButtonState) -> Void)?
    var onRotation: ((Rotation, Direction) -> Void)?
    
    init() {
        hid_init()
    }
    
    deinit {
        stop()
        hid_exit()
    }
    
    func start() {
        self.thread = Thread(target: self, selector: #selector(threadProc(arg:)), object: nil);
        
        run = true;
        thread!.start()
    }
    
    func stop() {
        device.updateSensitivity(sensitivity: .natural, haptics: false)
        run = false
        
        if let thread {
            semaphore.signal()
            device.disconnect()
            
            while !thread.isFinished { }
            self.thread = nil
        }
    }
    
    private func connect() -> Bool {
        false
    }
    
    @objc
    private func threadProc(arg: NSObject) {
        
        while run {
            if !device.isConnected {
                print("Trying to open device...")
                
                if device.connect() {
                    print("Device \(device.serialNumber) opened.")
                    device.buzz(3)
                    device.updateSensitivity() // thanks @bernhard-adobe
                } else {
                    print("Device couldn't be opened.")
                }
            }
            
            while device.isConnected {
                switch device.read() {
                case .dial(let buttonState, let rotation):
                    switch buttonState {
                    case .pressed where lastButtonState == .released:
                        onButtonStateChanged?(.pressed)
                    case .released where lastButtonState == .pressed:
                        onButtonStateChanged?(.released)
                    default: break
                    }
                    
                    if rotation != nil {
                        onRotation?(rotation!, Data.direction)
                    }
                    
                    self.lastButtonState = buttonState
                    break
                case .unknown:
                    print("Unknown input report.")
                    break
                case nil:
                    print("Device disconnected.")
                    break
                }
            }
            
            let _ = semaphore.wait(timeout: .now().advanced(by: .seconds(60)))
        }
    }
    
}
