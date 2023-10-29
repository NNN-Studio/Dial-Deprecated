
import Cocoa
import ServiceManagement
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var instance: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }

    var statusBarController: StatusBarController?
    
    var dialWindow: DialWindow?
    
    let dial = Dial()
    
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
        dial.start()
        
        statusBarController = StatusBarController(dial)
        dialWindow = DialWindow(
            contentRect: NSRect.zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        dialWindow?.isReleasedWhenClosed = false
        dialWindow?.animationBehavior = .utilityWindow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        dial.stop()
    }
    
}

extension AppDelegate {
    
    func buzz(_ repeatCount: UInt8 = 1) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dial.device.buzz(repeatCount)
        }
    }
    
    func showDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dialWindow?.show()
        }
    }
    
    func hideDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dialWindow?.show()
        }
    }
    
    func updateDialWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dialWindow?.updatePosition(true)
            (self.dialWindow?.contentViewController as? WindowController)?.updateColoredWidgets()
        }
    }
    
}

