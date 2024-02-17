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
    
    @IBOutlet weak var viewShortcuts3: NSStackView!
    
    @IBOutlet weak var viewOptions1: NSStackView!
    
    @IBOutlet weak var viewOptions2: NSStackView!
    
    // MARK: - Interactives
    
    @IBOutlet weak var segmentedControlShortcutsAdvanced: NSSegmentedControl!
    
    
    
    @IBOutlet weak var popUpButtonControllerSelector: NSPopUpButton!
    
    @IBOutlet weak var switchControllerActivated: NSSwitch!
    
    @IBOutlet weak var buttonDeleteController: NSButton!
    
    @IBOutlet weak var buttonAddController: NSButton!
    
    
    
    @IBOutlet weak var textFieldControllerName: EditableTextField!
    
    @IBOutlet weak var buttonIconChooser: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts1Keys1: InputButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts1Keys2: InputButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts2Keys1: InputButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts2Keys2: InputButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts3Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts3Keys1: InputButton!
    
    @IBOutlet weak var popUpButtonShortcuts3Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var buttonShortcuts3Keys2: InputButton!
    
    
    
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
            
            .pressAndRotateClockwise: popUpButtonShortcuts2Modifiers1,
            .pressAndRotateCounterclockwise: popUpButtonShortcuts2Modifiers2,
            
            .clickSingle: popUpButtonShortcuts3Modifiers1,
            .clickDouble: popUpButtonShortcuts3Modifiers2
        ]
    }
    
    
    
    private var segment: Segment = .shortcuts
    
    enum Segment: Int {
        
        case shortcuts = 0
        
        case advanced = 1
        
    }
    
    
    
    private var iconChooserPopover: NSPopover = .init()
    
    private var iconChooserViewController = IconChooserViewController()
    
}

extension ControllersViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultControllerMenuItems = .init(delegate: self, source: .default)
        shortcutsControllerMenuItems = .init(delegate: self, source: .shortcuts)
        
        rotationTypeMenuItems = .init(delegate: self)
        
        modifiersMenuItemsArray = [
            .rotateClockwise: .init(delegate: self, actionTarget: .rotateClockwise),
            .rotateCounterclockwise: .init(delegate: self, actionTarget: .rotateCounterclockwise),
            
            .pressAndRotateClockwise: .init(delegate: self, actionTarget: .pressAndRotateClockwise),
            .pressAndRotateCounterclockwise: .init(delegate: self, actionTarget: .pressAndRotateCounterclockwise),
            
            .clickSingle: .init(delegate: self, actionTarget: .clickSingle),
            .clickDouble: .init(delegate: self, actionTarget: .clickDouble)
        ]
        
        iconChooserPopover.delegate = self
        iconChooserPopover.contentViewController = iconChooserViewController
        iconChooserPopover.contentSize = .zero
        iconChooserPopover.behavior = .transient
        
        initDescriptives()
        initInteractives()
    }
    
    func initDescriptives() {
        labelRotationType.stringValue = Localization.Controllers.Advanced.rotationType.localizedName
        labelHaptics.stringValue = Localization.Controllers.Advanced.haptics.localizedName
        labelPhysicalDirection.stringValue = Localization.Controllers.Advanced.physicalDirection.localizedName
        labelAlternativeDirection.stringValue = Localization.Controllers.Advanced.alternativeDirection.localizedName
        
        loadDialCircleViewInto(viewDialCircle)
        
        func applyConnectionStatus(_ value: Device.ConnectionStatus) {
            switch value {
            case .connected(let serialNumber):
                labelSerial.stringValue = serialNumber
            default:
                labelSerial.stringValue = Localization.ConnectionStatus.offPlaceholder.localizedName
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
                    viewShortcuts3.isHidden = true
                    viewOptions1.isHidden = true
                    viewOptions2.isHidden = true
                    
                    segmentedControlShortcutsAdvanced.isHidden = true
                    
                    buttonDeleteController.isEnabled = false
                    buttonAddController.isEnabled = true
                    
                    iconChooserViewController.setAll(false)
                }
                
                else if let shortcutsController = controller as? ShortcutsController {
                    let settings = shortcutsController.settings
                    
                    viewDefaultControllerLabels.isHidden = true
                    viewControllerName.isHidden = false
                    
                    updateSegment(self.segment)
                    
                    segmentedControlShortcutsAdvanced.isHidden = false
                    
                    buttonDeleteController.isEnabled = true
                    buttonAddController.isEnabled = true
                    
                    textFieldControllerName.stringValue = settings.name ?? ""
                    
                    switchHaptics.flag = settings.haptics
                    switchPhysicalDirection.flag = settings.physicalDirection
                    switchAlternativeDirection.flag = settings.alternativeDirection
                    
                    refreshRotationTypeMenuManager()
                    popUpButtonRotationType.menu = rotationTypeMenuManager?.menu
                    
                    let icon = settings.representingSymbol
                    buttonIconChooser.image = icon.image
                    iconChooserViewController.setAll(true)
                    iconChooserViewController.chosen = icon
                    
                    for (index, item) in popUpButtonRotationType.itemArray.enumerated() {
                        if
                            let rotationType = item.representedObject as? Rotation.RawType,
                            rotationType == settings.rotationType
                        { popUpButtonRotationType.selectItem(at: index) }
                    }
                    
                    refreshModifiersMenuManagers()
                    
                    popUpButtonShortcuts1Modifiers1.menu = modifiersMenuManagers[.rotateClockwise]?.menu
                    popUpButtonShortcuts1Modifiers2.menu = modifiersMenuManagers[.rotateCounterclockwise]?.menu
                    
                    popUpButtonShortcuts2Modifiers1.menu = modifiersMenuManagers[.pressAndRotateClockwise]?.menu
                    popUpButtonShortcuts2Modifiers2.menu = modifiersMenuManagers[.pressAndRotateCounterclockwise]?.menu
                    
                    popUpButtonShortcuts3Modifiers1.menu = modifiersMenuManagers[.clickSingle]?.menu
                    popUpButtonShortcuts3Modifiers2.menu = modifiersMenuManagers[.clickDouble]?.menu
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
        
        Task { @MainActor in
            for await value in observationTrackingStream({ self.iconChooserViewController.chosen }) {
                if 
                    let settings = Controllers.selectedSettings,
                    settings.representingSymbol != value
                {
                    Controllers.selectedSettings?.representingSymbol = value
                }
            }
        }
    }
    
}

extension ControllersViewController: NSMenuDelegate {
    
    func refreshControllersMenuManager() {
        controllersMenuManager = .init(delegate: self) {
            var items: [MenuManager.MenuItemGroup] = []
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString(
                    "Menu/Title/DefaultControllers",
                    value: "Default",
                    comment: "default controllers"
                ),
                defaultControllerMenuItems!.controllers
            ))
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString(
                    "Menu/Title/ShortcutsControllers",
                    value: "Custom",
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

extension ControllersViewController: NSPopoverDelegate {
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        true
    }
    
}

extension ControllersViewController {
    
    func updateSegment(_ segment: Segment) {
        self.segment = segment
        
        switch segment {
        case .shortcuts:
            viewShortcuts1.isHidden = false
            viewShortcuts2.isHidden = false
            viewShortcuts3.isHidden = false
            viewOptions1.isHidden = true
            viewOptions2.isHidden = true
        case .advanced:
            viewShortcuts1.isHidden = true
            viewShortcuts2.isHidden = true
            viewShortcuts3.isHidden = true
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
        guard let item = sender as? MenuOptionItem<Rotation.RawType> else { return }
        
        Controllers.selectedSettings?.rotationType = item.option
    }
    
}

extension ControllersViewController: DialModifiersMenuDelegate {
    
    func setModifiers(_ sender: Any?) {
        // Well, this hack makes @IBAction unnecessary
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
        Controllers.selectedSettings?.name = sender.stringValue.isEmpty ? nil : sender.stringValue
        AppDelegate.loseFocus()
    }
    
    @IBAction func openIconChooser(_ sender: NSButton) {
        AppDelegate.loseFocus()
        
        if iconChooserPopover.isShown {
            iconChooserPopover.close()
        } else {
            iconChooserPopover.show(
                relativeTo: sender.visibleRect,
                of: sender,
                preferredEdge: .maxX
            )
            
            iconChooserViewController.scrollToChosen()
        }
    }
    
    @IBAction func toggleShortcutsKeys(_ sender: InputButton) {
        if sender == buttonShortcuts1Keys1 {
            Controllers.selectedSettings?.shortcuts.rotation[.clockwise]?.keys = sender.keys
        }
        
        if sender == buttonShortcuts1Keys2 {
            Controllers.selectedSettings?.shortcuts.rotation[.counterclockwise]?.keys = sender.keys
        }
        
        if sender == buttonShortcuts2Keys1 {
            Controllers.selectedSettings?.shortcuts.pressedRotation[.clockwise]?.keys = sender.keys
        }
        
        if sender == buttonShortcuts2Keys2 {
            Controllers.selectedSettings?.shortcuts.pressedRotation[.counterclockwise]?.keys = sender.keys
        }
        
        if sender == buttonShortcuts3Keys1 {
            Controllers.selectedSettings?.shortcuts.single.keys = sender.keys
        }
        
        if sender == buttonShortcuts3Keys2 {
            Controllers.selectedSettings?.shortcuts.double.keys = sender.keys
        }
    }
    
}

extension ControllersViewController {
    
    // MARK: - Advanced options
    
    @IBAction func toggleRotationType(_ sender: NSPopUpButton) {
        guard
            let item = sender.selectedItem,
            let rotationType = item.representedObject as? Rotation.RawType
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
