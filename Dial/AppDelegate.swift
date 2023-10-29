
import Cocoa
import ServiceManagement
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var instance: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }

    static let statusBarController = StatusBarController()
    
    static let dial = Dial()
    
    static let dialWindow = DialWindow(
        contentRect: NSRect.zero,
        styleMask: [.borderless],
        backing: .buffered,
        defer: true
    )
    
    func requestPermissions() {
        // More information on this behaviour: https://stackoverflow.com/questions/29006379/accessibility-permissions-reset-after-application-update
        if !AXIsProcessTrusted() {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("App/PermissionsAlert/Title", value: "Permissions Required", comment: "permissions alert title")
            alert.alertStyle = NSAlert.Style.informational
            alert.informativeText = NSLocalizedString(
                "App/PermissionsAlert/Content",
                value: "Dial needs Accessibility permissions to function properly. In the next dialog, you will be asked to open the Settings in order to grant them.",
                comment: "permissions alert content")
            alert.runModal()
        }
        
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        
        AXIsProcessTrustedWithOptions(options)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Data.registerDefaults()
        requestPermissions()
        AppDelegate.dial.start()
        
        AppDelegate.dialWindow.isReleasedWhenClosed = false
        AppDelegate.dialWindow.animationBehavior = .utilityWindow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        AppDelegate.dial.stop()
    }
    
}

extension AppDelegate {
    
    func buzz(_ repeatCount: UInt8 = 1) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.dial.device.buzz(repeatCount)
        }
    }
    
    func showDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.dialWindow.show()
        }
    }
    
    func hideDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.dialWindow.hide()
        }
    }
    
    func updateDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.dialWindow.updatePosition(true)
            (AppDelegate.dialWindow.contentViewController as? WindowController)?.updateColoredWidgets()
        }
    }
    
}

