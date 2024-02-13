//
//  SettingsControllersViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit
import Defaults

class ControllersViewController: NSViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var viewDialCircle: NSView!
    
    @IBOutlet weak var viewDefaultControllerLabels: NSStackView!
    
    @IBOutlet weak var viewControllerName: NSStackView!
    
    @IBOutlet weak var viewShortcuts1: NSStackView!
    
    @IBOutlet weak var viewShortcuts2: NSStackView!
    
    @IBOutlet weak var viewOptions1: NSStackView!
    
    @IBOutlet weak var viewOptions2: NSStackView!
    
    // MARK: - Interactives
    
    @IBOutlet weak var segmentedControlShortcutsAdvanced: NSSegmentedControl!
    
    
    
    @IBOutlet weak var popUpButtonControllerSelector: NSPopUpButton!
    
    @IBOutlet weak var switchControllerActivated: NSSwitch!
    
    @IBOutlet weak var buttonDeleteController: NSButton!
    
    @IBOutlet weak var buttonAddController: NSButton!
    
    
    
    @IBOutlet weak var textFieldControllerName: NSTextField!
    
    @IBOutlet weak var buttonIconChooser: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Keys1: NSButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Keys2: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Keys1: NSButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Keys2: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonRotationType: NSPopUpButton!
    
    @IBOutlet weak var switchHaptics: NSSwitch!
    
    @IBOutlet weak var switchPhysicalDirection: NSSwitch!
    
    @IBOutlet weak var switchAlternativeDirection: NSSwitch!
    
    // MARK: - Descriptives
    
    @IBOutlet weak var labelRotationType: NSTextField!
    
    @IBOutlet weak var labelHaptics: NSTextField!
    
    @IBOutlet weak var labelPhysicalDirection: NSTextField!
    
    @IBOutlet weak var labelAlternativeDirection: NSTextField!
    
    
    
    @IBOutlet weak var labelDefaultControllerDescription: NSTextField!
    
    @IBOutlet weak var labelSerial: NSTextField!
    
    // MARK: - Others
    
    private var controllersMenuManager: MenuManager?
    
    private var defaultControllerMenuItems: ControllerMenuItems?
    
    private var shortcutsControllerMenuItems: ControllerMenuItems?
    
    private var segment: Segment = .shortcuts
    
    enum Segment: Int {
        
        case shortcuts = 0
        
        case advanced = 1
        
    }
    
}

extension ControllersViewController {
    
    // MARK: - Storyboard Instantiation
    
    static func freshController() -> ControllersViewController {
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil
        )
        
        let identifier = NSStoryboard.SceneIdentifier("ControllersController")
        
        guard let controller = storyboard.instantiateController(
            withIdentifier: identifier
        ) as? ControllersViewController else {
            fatalError("Can not find ControllersController")
        }
        
        return controller
    }
    
}

extension ControllersViewController: NSMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultControllerMenuItems = .init(delegate: self, source: .default)
        shortcutsControllerMenuItems = .init(delegate: self, source: .shortcuts)
        
        initDescriptives()
        initInteractives()
    }
    
    func refreshMenuManager() {
        controllersMenuManager = .init(delegate: self) {
            var items: [MenuManager.MenuItemGroup] = []
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString(
                    "Menu/Title/DefaultControllers",
                    value: "Default Controllers",
                    comment: "default controllers"
                ),
                defaultControllerMenuItems!.controllers
            ))
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString(
                    "Menu/Title/ShortcutsControllers",
                    value: "Custom Controllers",
                    comment: "shortcuts controllers"
                ),
                shortcutsControllerMenuItems!.controllers
            ))
            
            return items
        }
    }
    
    func initDescriptives() {
        func applyConnectionStatus(_ value: Device.ConnectionStatus) {
            switch value {
            case .connected(let serialNumber):
                labelSerial.stringValue = serialNumber
            default:
                labelSerial.stringValue = Localization.ConnectionStatus.offOld.localizedName
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ AppDelegate.shared?.dial.device.connectionStatus }) {
                if let value { applyConnectionStatus(value) }
            }
        }
    }
    
    func initInteractives() {
        updateSelectedController(Controllers.currentController)
    }
    
}

extension ControllersViewController {
    
    func updateSelectedController(_ controller: Controller) {
        let canActivate = Controllers.activatedControllers.count > 1
        
        switchControllerActivated.flag = Controllers.activatedControllers.contains(where: { $0.id == controller.id })
        switchControllerActivated.isEnabled = canActivate
        
        if let defaultController = controller as? DefaultController {
            labelDefaultControllerDescription.stringValue = defaultController.description
            
            viewDefaultControllerLabels.isHidden = false
            viewControllerName.isHidden = true
            
            viewShortcuts1.isHidden = true
            viewShortcuts2.isHidden = true
            viewOptions1.isHidden = true
            viewOptions2.isHidden = true
            
            segmentedControlShortcutsAdvanced.isEnabled = false
            
            buttonDeleteController.isEnabled = false
            buttonAddController.isEnabled = true
        } else {
            viewDefaultControllerLabels.isHidden = true
            viewControllerName.isHidden = false
            
            updateSegment(self.segment)
            
            segmentedControlShortcutsAdvanced.isEnabled = true
            
            buttonDeleteController.isEnabled = true
            buttonAddController.isEnabled = true
        }
        
        refreshMenuManager()
        popUpButtonControllerSelector.menu = controllersMenuManager?.menu
        let index = popUpButtonControllerSelector.indexOfItem(withRepresentedObject: controller)
        popUpButtonControllerSelector.selectItem(at: index)
    }
    
    func updateSegment(_ segment: Segment) {
        self.segment = segment
        
        switch segment {
        case .shortcuts:
            viewShortcuts1.isHidden = false
            viewShortcuts2.isHidden = false
            viewOptions1.isHidden = true
            viewOptions2.isHidden = true
        case .advanced:
            viewShortcuts1.isHidden = true
            viewShortcuts2.isHidden = true
            viewOptions1.isHidden = false
            viewOptions2.isHidden = false
        }
    }
    
}

extension ControllersViewController: DialControllerMenuDelegate {
    
    func setController(_ sender: Any?) {
        guard let item = sender as? ControllerOptionItem else { return }
        
        updateSelectedController(item.option)
    }
    
}

extension ControllersViewController {
    
    @IBAction func switchSegment(_ sender: NSSegmentedControl) {
        if let nextSegment = Segment(rawValue: sender.indexOfSelectedItem) {
            updateSegment(nextSegment)
        }
    }
    
    @IBAction func toggleController(_ sender: NSSwitch) {
        Controllers.toggle(sender.flag, controller: Controllers.currentController)
    }
    
    @IBAction func deleteController(_ sender: NSButton) {
        Controllers.remove(Controllers.currentController)
        
        refreshMenuManager()
        popUpButtonControllerSelector.menu = controllersMenuManager?.menu
        let index = popUpButtonControllerSelector.indexOfItem(withRepresentedObject: Controllers.defaultControllers.first)
        popUpButtonControllerSelector.selectItem(at: index)
    }
    
    @IBAction func addController(_ sender: NSButton) {
        Controllers.append()
        
        refreshMenuManager()
        popUpButtonControllerSelector.menu = controllersMenuManager?.menu
        let index = popUpButtonControllerSelector.indexOfItem(withRepresentedObject: Controllers.shortcutsControllers.last)
        popUpButtonControllerSelector.selectItem(at: index)
    }
    
}
