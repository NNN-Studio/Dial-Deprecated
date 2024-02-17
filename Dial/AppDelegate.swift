import Cocoa
import LaunchAtLogin
import ServiceManagement
import SwiftUI
import Defaults

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var dial = Dial()
    
    func requestPermissions() {
        // More information on this behaviour: https://stackoverflow.com/questions/29006379/accessibility-permissions-reset-after-application-update
        if !AXIsProcessTrusted() {
            let alert = NSAlert()
            
            alert.messageText = NSLocalizedString("App/PermissionsAlert/Title", value: "Permissions Required", comment: "permissions alert title")
            alert.alertStyle = NSAlert.Style.informational
            alert.informativeText = NSLocalizedString(
                "App/PermissionsAlert/Content",
                value: """
Dial needs Accessibility permissions to function properly. In the next dialog, you will be asked to open the Settings in order to grant them.
Due to an issue in macOS, if you're upgrading from an earlier version of Dial, you might have to remove Dial from the accessibility permissions and then restart the app to re-add the permissions.
""",
                comment: "permissions alert content")
            
            alert.runModal()
        }
        
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        requestPermissions()
        runTasks()
        
        /*
        // TODO: DEBUG
        Defaults.reset(.activatedControllerIDs)
        Defaults.reset(.shortcutsControllerSettings)
        Defaults.reset(.currentControllerID)
        Defaults.reset(.selectedControllerID)
         */
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            SettingsWindowController.shared?.showWindow(nil)
        }
        
        return false
    }
    
}

extension AppDelegate {
    
    static var shared: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }
    
    static var version: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
}

extension AppDelegate {
    
    static func openSettings() {
        SettingsWindowController.shared?.showWindow(nil)
    }
    
    static func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    static func loseFocus() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
    
}

func runTasks() {
    Task { @MainActor in
        for await value in Defaults.updates(.autoHidesIconEnabled) {
            AppDelegate.shared?.dial.statusBarController.toggleVisibility(!value || (AppDelegate.shared?.dial.device.isConnected ?? false))
        }
    }
    
    Task { @MainActor in
        for await value in Defaults.updates(.launchAtLogin) {
            LaunchAtLogin.isEnabled = value
        }
    }
}

func setCursorVisibility(
    _ visible: Bool
) {
    // TODO: DEBUG
    return
    
    let propertyString = CFStringCreateWithCString(kCFAllocatorDefault, "SetsCursorInBackground", 0)
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue)
    
    if visible {
        NSCursor.unhide()
    } else {
        NSCursor.hide()
    }
}

