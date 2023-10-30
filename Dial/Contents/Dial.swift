
import Foundation
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device = Device()
    
    var statusBarController = StatusBarController()
    
    init() {
        device.eventHandler = self
        connect()
    }
    
}

extension Dial {
    
    func connect() {
        device.start()
    }
    
    func disconnect() {
        device.stop()
    }
    
    func reconnect() {
        disconnect()
        connect()
    }
    
}

extension Dial: DeviceEventHandler {
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        statusBarController.onConnectionStatusChanged(isConnected, serialNumber)
    }
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState) {
        
    }
    
    func onRotation(_ rotation: Device.Rotation) {
        
    }
    
}
