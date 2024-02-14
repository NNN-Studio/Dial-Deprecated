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
    
    @IBOutlet weak var buttonShortcuts1Keys1: InputButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts1Keys2: InputButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts2Keys1: InputButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts2Keys2: InputButton!
    
    
    
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
    
    
    
    private var rotationTypeMenuManager: MenuManager?
    
    private var rotationTypeMenuItems: RotationTypeMenuItems?
    
    
    
    private var modifiersMenuManagers: [ModifiersOptionItem.ActionTarget: MenuManager] = [:]
    
    private var modifiersMenuItemsArray: [ModifiersOptionItem.ActionTarget: ModifiersMenuItems] = [:]
    
    private var popUpButtonShortcutsModifiersArray: [ModifiersOptionItem.ActionTarget: NSPopUpButton] {
        [
            .rotateClockwise: popUpButtonShortcuts1Modifiers1,
            .rotateCounterclockwise: popUpButtonShortcuts1Modifiers2,
            .clickSingle: popUpButtonShortcuts2Modifiers1,
            .clickDouble: popUpButtonShortcuts2Modifiers2
        ]
    }
    
    
    
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
        
        rotationTypeMenuItems = .init(delegate: self)
        
        modifiersMenuItemsArray = [
            .rotateClockwise: .init(delegate: self, actionTarget: .rotateClockwise),
            .rotateCounterclockwise: .init(delegate: self, actionTarget: .rotateCounterclockwise),
            .clickSingle: .init(delegate: self, actionTarget: .clickSingle),
            .clickDouble: .init(delegate: self, actionTarget: .clickDouble)
        ]
        
        initDescriptives()
        initInteractives()
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
        Task { @MainActor in
            for await _ in Defaults.updates([
                .selectedControllerID,
                .shortcutsControllerSettings
            ]) {
                let controller = Controllers.selectedController
                
                let canDeactivate = Controllers.activatedControllers.count > 1
                let canActivate = Controllers.activatedControllers.count < Defaults[.maxControllerCount]
                
                let activated = Controllers.activatedControllers.contains(where: { $0.id == controller.id })
                switchControllerActivated.flag = activated
                switchControllerActivated.isEnabled = (activated && canDeactivate) || (!activated && canActivate)
                
                if let defaultController = controller as? DefaultController {
                    labelDefaultControllerDescription.stringValue = defaultController.description
                    
                    viewDefaultControllerLabels.isHidden = false
                    viewControllerName.isHidden = true
                    
                    viewShortcuts1.isHidden = true
                    viewShortcuts2.isHidden = true
                    viewOptions1.isHidden = true
                    viewOptions2.isHidden = true
                    
                    segmentedControlShortcutsAdvanced.isHidden = true
                    
                    buttonDeleteController.isEnabled = false
                    buttonAddController.isEnabled = true
                }
                
                else if let shortcutsController = controller as? ShortcutsController {
                    viewDefaultControllerLabels.isHidden = true
                    viewControllerName.isHidden = false
                    
                    updateSegment(self.segment)
                    
                    segmentedControlShortcutsAdvanced.isHidden = false
                    
                    buttonDeleteController.isEnabled = true
                    buttonAddController.isEnabled = true
                    
                    textFieldControllerName.stringValue = shortcutsController.settings.name ?? ""
                    
                    switchHaptics.flag = shortcutsController.settings.haptics
                    switchPhysicalDirection.flag = shortcutsController.settings.physicalDirection
                    switchAlternativeDirection.flag = shortcutsController.settings.alternativeDirection
                    
                    refreshRotationTypeMenuManager()
                    popUpButtonRotationType.menu = rotationTypeMenuManager?.menu
                    
                    for (index, item) in popUpButtonRotationType.itemArray.enumerated() {
                        if
                            let rotationType = item.representedObject as? Dial.Rotation.RawType,
                            rotationType == shortcutsController.settings.rotationType
                        { popUpButtonRotationType.selectItem(at: index) }
                    }
                    
                    refreshModifiersMenuManagers()
                    
                    popUpButtonShortcuts1Modifiers1.menu = modifiersMenuManagers[.rotateClockwise]?.menu
                    popUpButtonShortcuts1Modifiers2.menu = modifiersMenuManagers[.rotateCounterclockwise]?.menu
                    
                    popUpButtonShortcuts2Modifiers1.menu = modifiersMenuManagers[.clickSingle]?.menu
                    popUpButtonShortcuts2Modifiers2.menu = modifiersMenuManagers[.clickDouble]?.menu
                }
                
                refreshControllersMenuManager()
                popUpButtonControllerSelector.menu = controllersMenuManager?.menu
                
                for (index, item) in popUpButtonControllerSelector.itemArray.enumerated() {
                    if
                        let controller = item.representedObject as? Controller,
                        controller.id == Controllers.selectedController.id
                    { popUpButtonControllerSelector.selectItem(at: index) }
                    
                }
            }
        }
    }
    
}

extension ControllersViewController {
    
    func refreshControllersMenuManager() {
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
    
    func refreshRotationTypeMenuManager() {
        rotationTypeMenuManager = .init(delegate: self) {
            var items: [MenuManager.MenuItemGroup] = []
            
            items.append(MenuManager.groupItems(rotationTypeMenuItems!.rotationTypeOptions))
            
            return items
        }
    }
    
    func refreshModifiersMenuManagers() {
        for actionTarget in ModifiersOptionItem.ActionTarget.allCases {
            modifiersMenuManagers[actionTarget] = .init(delegate: self) {
                var items: [MenuManager.MenuItemGroup] = []
                
                items.append(MenuManager.groupItems(modifiersMenuItemsArray[actionTarget]!.modifiersOptions))
                
                return items
            }
        }
    }
    
}

extension ControllersViewController {
    
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
        
        Controllers.selectedController = item.option
    }
    
}

extension ControllersViewController: DialRotationTypeMenuDelegate {
    
    func setRotationType(_ sender: Any?) {
        guard let item = sender as? MenuOptionItem<Dial.Rotation.RawType> else { return }
        
        Controllers.selectedSettings?.rotationType = item.option
    }
    
}

extension ControllersViewController: DialModifiersMenuDelegate {
    
    func setModifiers(_ sender: Any?) {
        guard let option = sender as? ModifiersOptionItem else { return }
        
        option.flag.toggle()
        Controllers.selectedSettings?.shortcuts.setModifiersFor(
            option.actionTarget,
            modifiers: option.option,
            activated: option.flag
        )
    }
    
}

extension ControllersViewController {
    
    // MARK: - Leading controls
    
    @IBAction func switchSegment(_ sender: NSSegmentedControl) {
        if let nextSegment = Segment(rawValue: sender.indexOfSelectedItem) {
            updateSegment(nextSegment)
        }
    }
    
    @IBAction func toggleController(_ sender: NSSwitch) {
        Controllers.toggle(sender.flag, controller: Controllers.selectedController)
    }
    
    @IBAction func deleteController(_ sender: NSButton) {
        guard let selectedController = Controllers.selectedController as? ShortcutsController else { return }
        
        var previous: Controller?
        var next: Controller?
        var found = false
        
        for item in popUpButtonControllerSelector.itemArray{
            if let controller = item.representedObject as? ShortcutsController {
                if controller.id == selectedController.id { found = true }
                else if !found { previous = controller }
                else if found && next == nil { next = controller }
            }
        }
        
        Controllers.remove(selectedController)
        
        if let next {
            Controllers.selectedController = next
        } else if let previous {
            Controllers.selectedController = previous
        } else {
            Controllers.selectedController = Controllers.defaultControllers.last!
        }
    }
    
    @IBAction func addController(_ sender: NSButton) {
        let controller = Controllers.append()
        
        Controllers.selectedController = controller
        Controllers.toggle(true, controller: controller)
    }
    
}

extension ControllersViewController {
    
    // MARK: - Shortcuts options
    
    @IBAction func rename(_ sender: NSTextField) {
        print(sender.stringValue)
        Controllers.selectedSettings?.name = sender.stringValue
    }
    
    @IBAction func openIconChooser(_ sender: NSButton) {
        
    }
    
    @IBAction func toggleShortcutsKeys(_ sender: InputButton) {
        print(sender.flag)
        if sender.flag { sender.flag = false }
    }
    
}

extension ControllersViewController {
    
    // MARK: - Advanced options
    
    @IBAction func toggleRotationType(_ sender: NSPopUpButton) {
        guard
            let item = sender.selectedItem,
            let rotationType = item.representedObject as? Dial.Rotation.RawType
        else { return }
        
        Controllers.selectedSettings?.rotationType = rotationType
    }

    @IBAction func toggleHaptics(_ sender: NSSwitch) {
        Controllers.selectedSettings?.haptics = sender.flag
    }
    
    @IBAction func togglePhysicalDirection(_ sender: NSSwitch) {
        Controllers.selectedSettings?.physicalDirection = sender.flag
    }
    
    @IBAction func toggleAlternativeDirection(_ sender: NSSwitch) {
        Controllers.selectedSettings?.alternativeDirection = sender.flag
    }
    
}
