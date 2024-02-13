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
""",
                comment: "permissions alert content")
            
            alert.runModal()
        }
        
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        
        AXIsProcessTrustedWithOptions(options)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        requestPermissions()
        runTasks()
        //test()
        Defaults.reset(.activatedControllerIDs)
        Defaults.reset(.shortcutsControllerSettings)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            SettingsWindowController.shared.showWindow(nil)
        }
        
        return false
    }
    
}

extension AppDelegate {
    
    func test() {
        Defaults.reset([.activatedControllerIDs])
        Defaults.reset([.shortcutsControllerSettings])
        
        print(1)
        print(Defaults[.activatedControllerIDs])
        print()
        print(Defaults[.shortcutsControllerSettings])
        print()
        
        Controllers.append()
        print(2)
        print(Defaults[.activatedControllerIDs])
        print()
        print(Defaults[.shortcutsControllerSettings])
        print()
        
        Controllers.toggle(false, menuIndex: 0)
        Controllers.toggle(true, menuIndex: 4)
        print(3)
        print(Defaults[.activatedControllerIDs])
        print()
        print(Defaults[.shortcutsControllerSettings])
        print()
    }
    
}

extension AppDelegate {
    
    static var shared: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }
    
}

extension AppDelegate {
    
    static func openSettings() {
        SettingsWindowController.shared.showWindow(nil)
    }
    
    static func quitApp() {
        NSApplication.shared.terminate(self)
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
    let propertyString = CFStringCreateWithCString(kCFAllocatorDefault, "SetsCursorInBackground", 0)
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue)
    
    if visible {
        NSCursor.unhide()
    } else {
        NSCursor.hide()
    }
}

