
import Cocoa
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
                value: "Dial needs Accessibility permissions to function properly. In the next dialog, you will be asked to open the Settings in order to grant them.",
                comment: "permissions alert content")
            alert.runModal()
        }
        
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        
        AXIsProcessTrustedWithOptions(options)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        requestPermissions()
        print(1, Defaults[.activatedControllerIndexes])
        Controllers.toggle(true, index: 3)
        print(2, Defaults[.activatedControllerIndexes])
        Controllers.toggle(true, index: 4)
        Controllers.toggle(true, index: 5)
        Controllers.toggle(false, index: 3)
        print(3, Defaults[.activatedControllerIndexes])
        Controllers.toggle(true, index: 10)
        Controllers.toggle(true, index: 20)
        print(4, Defaults[.activatedControllerIndexes])
        Controllers.reorder(fetchAt: 2, insertAt: 5)
        print("reordered", Defaults[.activatedControllerIndexes])
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (!flag) {
            SettingsWindowController.shared.showWindow(nil)
        }
        
        return false
    }
    
}

extension AppDelegate {
    
    static var instance: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
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

