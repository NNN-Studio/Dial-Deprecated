//
//  SettingsControllersViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit
import Defaults
import SFSafeSymbols

class ControllersViewController: NSViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var viewHeader: NSStackView!
    
    @IBOutlet weak var viewSegmentedControllers: NSStackView!
    
    @IBOutlet weak var viewSettings: NSStackView!
    
    @IBOutlet weak var viewDefaultControllerLabels: NSStackView!
    
    @IBOutlet weak var viewControllerName: NSStackView!
    
    @IBOutlet weak var viewShortcuts1_1: NSStackView!
    
    @IBOutlet weak var viewShortcuts1_2: NSStackView!
    
    @IBOutlet weak var separatorShortcuts1Shortcuts2: NSBox!
    
    @IBOutlet weak var viewShortcuts2_1: NSStackView!
    
    @IBOutlet weak var viewShortcuts2_2: NSStackView!
    
    @IBOutlet weak var separatorShortcuts2Shortcuts3: NSBox!
    
    @IBOutlet weak var viewShortcuts3_1: NSStackView!
    
    @IBOutlet weak var viewShortcuts3_2: NSStackView!
    
    @IBOutlet weak var separatorShortcuts3Options: NSBox!
    
    @IBOutlet weak var viewOptions: NSStackView!
    
    // MARK: - Interactives
    
    @IBOutlet weak var segmentedControlCollapsed: NSSegmentedControl!
    
    @IBOutlet weak var segmentedControlExpanded: NSSegmentedControl!
    
    
    
    @IBOutlet weak var popUpButtonControllerSelector: NSPopUpButton!
    
    @IBOutlet weak var switchControllerActivated: NSSwitch!
    
    @IBOutlet weak var segmentedControlAddOrDeleteController: NSSegmentedControl!
    
    @IBOutlet weak var segmentedControlResetController: NSSegmentedControl!
    
    
    
    @IBOutlet weak var textFieldControllerName: EditableTextField!
    
    @IBOutlet weak var buttonIconChooser: NSButton!
    
    
    
    @IBOutlet weak var segmentedControlShortcuts1Modifiers1: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts1Keys1: InputButton!
    
    @IBOutlet weak var segmentedControlShortcuts1Modifiers2: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts1Keys2: InputButton!
    
    
    
    @IBOutlet weak var segmentedControlShortcuts2Modifiers1: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts2Keys1: InputButton!
    
    @IBOutlet weak var segmentedControlShortcuts2Modifiers2: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts2Keys2: InputButton!
    
    
    
    @IBOutlet weak var segmentedControlShortcuts3Modifiers1: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts3Keys1: InputButton!
    
    @IBOutlet weak var segmentedControlShortcuts3Modifiers2: NSSegmentedControl!
    
    @IBOutlet weak var buttonShortcuts3Keys2: InputButton!
    
    
    
    @IBOutlet weak var switchHaptics: NSSwitch!
    
    @IBOutlet weak var popUpButtonRotationType: NSPopUpButton!
    
    @IBOutlet weak var switchPhysicalDirection: NSSwitch!
    
    @IBOutlet weak var switchAlternativeDirection: NSSwitch!
    
    // MARK: - Descriptives
    
    @IBOutlet weak var labelHaptics: NSTextField!
    
    @IBOutlet weak var labelRotationType: NSTextField!
    
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
            :
//            .rotateClockwise: popUpButtonShortcuts1Modifiers1,
//            .rotateCounterclockwise: popUpButtonShortcuts1Modifiers2,
//            
//            .pressAndRotateClockwise: popUpButtonShortcuts2Modifiers1,
//            .pressAndRotateCounterclockwise: popUpButtonShortcuts2Modifiers2,
//            
//            .clickSingle: popUpButtonShortcuts3Modifiers1,
//            .clickDouble: popUpButtonShortcuts3Modifiers2
        ]
    }
    
    
    
    private var segmentCollapsed: Segment = .dialing
    
    private var segmentExpanded: Segment = .shortcuts
    
    enum Segment: Int {
        
        case dialing = 0
        
        case pressing = 1
        
        case shortcuts = 2
        
        case advanced = 3
        
    }
    
    private var enabledSegmentedControl: EnabledSegmentedControl = .collapsed
    
    enum EnabledSegmentedControl {
        
        case collapsed
        
        case expanded
        
        case none
        
    }
    
    
    
    private var iconChooserPopover: NSPopover = .init()
    
    private var iconChooserViewController = IconChooserViewController()
    
}

extension ControllersViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        segmentedControlCollapsed.selectedSegment = 0
        segmentedControlExpanded.selectedSegment = 0
        
        updateEnabledSegmentedControl(.collapsed)
        updateSegment(.dialing)
        
        labelRotationType.stringValue = Localization.Controllers.Advanced.rotationType.localizedName
        labelHaptics.stringValue = Localization.Controllers.Advanced.haptics.localizedName
        labelPhysicalDirection.stringValue = Localization.Controllers.Advanced.physicalDirection.localizedName
        labelAlternativeDirection.stringValue = Localization.Controllers.Advanced.alternativeDirection.localizedName
        
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
        refreshControllersMenuManager()
        popUpButtonControllerSelector.select(popUpButtonControllerSelector.menu!.items.first {
            ($0 as? ControllerOptionItem)?.option.id == Controllers.selectedController.id
        })
        
        iconChooserViewController.chooseIconHandler = self
        
        rotationTypeMenuManager = .init(delegate: self) { [MenuManager.groupItems(rotationTypeMenuItems!.rotationTypeOptions)] }
        popUpButtonRotationType.menu = rotationTypeMenuManager?.menu
        
        for actionTarget in ModifiersOptionItem.ActionTarget.allCases {
            modifiersMenuManagers[actionTarget] = .init(delegate: self) { [MenuManager.groupItems(modifiersMenuItemsArray[actionTarget]!.modifierOptions)] }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.currentControllerID, .activatedControllerIDs]) {
                refreshControllersMenuManager()
            }
        }
        
//        popUpButtonShortcuts1Modifiers1.menu = modifiersMenuManagers[.rotateClockwise]?.menu
//        popUpButtonShortcuts1Modifiers2.menu = modifiersMenuManagers[.rotateCounterclockwise]?.menu
//        
//        popUpButtonShortcuts2Modifiers1.menu = modifiersMenuManagers[.pressAndRotateClockwise]?.menu
//        popUpButtonShortcuts2Modifiers2.menu = modifiersMenuManagers[.pressAndRotateCounterclockwise]?.menu
//        
//        popUpButtonShortcuts3Modifiers1.menu = modifiersMenuManagers[.clickSingle]?.menu
//        popUpButtonShortcuts3Modifiers2.menu = modifiersMenuManagers[.clickDouble]?.menu
    }
    
}

extension ControllersViewController {
    
    override func viewDidLayout() {
        let height = view.bounds.height
    }
    
}

extension ControllersViewController: ChooseIconHandler {
    
    func chooseIcon(_ icon: SFSymbol) {
        if
            let settings = Controllers.selectedSettings,
            settings.representingSymbol != icon
        {
            Controllers.selectedSettings?.representingSymbol = icon
        }
    }
    
}

extension ControllersViewController: NSMenuDelegate {
    
    func refreshControllersMenuManager() {
        controllersMenuManager = .init(delegate: self) {
            defaultControllerMenuItems = .init(delegate: self, source: .default)
            shortcutsControllerMenuItems = .init(delegate: self, source: .shortcuts)
            
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
        
        popUpButtonControllerSelector.menu = controllersMenuManager?.menu
    }
    
}

extension ControllersViewController: NSPopoverDelegate {
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool { true }
    
}

extension ControllersViewController {
    
    func updateEnabledSegmentedControl(_ enabledSegmentedControl: EnabledSegmentedControl) {
        self.enabledSegmentedControl = enabledSegmentedControl
        
        switch enabledSegmentedControl {
        case .collapsed:
            segmentedControlCollapsed.isHidden = false
            segmentedControlExpanded.isHidden = true
        case .expanded:
            segmentedControlCollapsed.isHidden = true
            segmentedControlExpanded.isHidden = false
        case .none:
            segmentedControlCollapsed.isHidden = true
            segmentedControlExpanded.isHidden = true
        }
    }
    
    func updateSegment(_ segment: Segment?) {
        if let segment {
            switch segment {
            case .dialing:
                viewShortcuts1_1.isHidden = false
                viewShortcuts1_2.isHidden = false
                
                separatorShortcuts1Shortcuts2.isHidden = false
                
                viewShortcuts2_1.isHidden = false
                viewShortcuts2_2.isHidden = false
                
                separatorShortcuts2Shortcuts3.isHidden = true
                
                viewShortcuts3_1.isHidden = true
                viewShortcuts3_2.isHidden = true
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = true
            case .pressing:
                viewShortcuts1_1.isHidden = true
                viewShortcuts1_2.isHidden = true
                
                separatorShortcuts1Shortcuts2.isHidden = true
                
                viewShortcuts2_1.isHidden = false
                viewShortcuts2_2.isHidden = false
                
                separatorShortcuts2Shortcuts3.isHidden = false
                
                viewShortcuts3_1.isHidden = false
                viewShortcuts3_2.isHidden = false
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = true
            case .shortcuts:
                viewShortcuts1_1.isHidden = false
                viewShortcuts1_2.isHidden = false
                
                separatorShortcuts1Shortcuts2.isHidden = false
                
                viewShortcuts2_1.isHidden = false
                viewShortcuts2_2.isHidden = false
                
                separatorShortcuts2Shortcuts3.isHidden = false
                
                viewShortcuts3_1.isHidden = false
                viewShortcuts3_2.isHidden = false
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = true
            case .advanced:
                viewShortcuts1_1.isHidden = true
                viewShortcuts1_2.isHidden = true
                
                separatorShortcuts1Shortcuts2.isHidden = true
                
                viewShortcuts2_1.isHidden = true
                viewShortcuts2_2.isHidden = true
                
                separatorShortcuts2Shortcuts3.isHidden = true
                
                viewShortcuts3_1.isHidden = true
                viewShortcuts3_2.isHidden = true
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = false
            }
        } else {
            // Shows all
            
            viewShortcuts1_1.isHidden = false
            viewShortcuts1_2.isHidden = false
            
            separatorShortcuts1Shortcuts2.isHidden = false
            
            viewShortcuts2_1.isHidden = false
            viewShortcuts2_2.isHidden = false
            
            separatorShortcuts2Shortcuts3.isHidden = false
            
            viewShortcuts3_1.isHidden = false
            viewShortcuts3_2.isHidden = false
            
            separatorShortcuts3Options.isHidden = false
            
            viewOptions.isHidden = false
        }
    }
    
}

extension ControllersViewController: DialControllerMenuDelegate {
    
    func setController(_ sender: Any?) {
        guard let item = sender as? ControllerOptionItem else { return }
                
        let controller = item.option
        Controllers.selectedController = controller
        
        let canDeactivate = Controllers.activatedControllers.count > 1
        let canActivate = Controllers.activatedControllers.count < Defaults[.maxControllerCount]
        
        let activated = Controllers.activatedControllers.contains(where: { $0.id == controller.id })
        switchControllerActivated.flag = activated
        switchControllerActivated.isEnabled = (activated && canDeactivate) || (!activated && canActivate)
        
        if let defaultController = controller as? DefaultController {
            labelDefaultControllerDescription.stringValue = defaultController.description
            
            viewDefaultControllerLabels.isHidden = false
            viewControllerName.isHidden = true
            
//            viewShortcuts1.isHidden = true
//            viewShortcuts2.isHidden = true
//            viewShortcuts3.isHidden = true
//            viewOptions1.isHidden = true
//            viewOptions2.isHidden = true
            
            segmentedControlExpanded.isHidden = true
            
//            buttonDeleteController.isEnabled = false
//            buttonAddController.isEnabled = true
            
            iconChooserViewController.setAll(false)
        }
        
        else if let shortcutsController = controller as? ShortcutsController {
            let settings = shortcutsController.settings
            
            viewDefaultControllerLabels.isHidden = true
            viewControllerName.isHidden = false
            
            updateSegment(self.segmentExpanded)
            
            segmentedControlExpanded.isHidden = false
            
//            buttonDeleteController.isEnabled = true
//            buttonAddController.isEnabled = true
            
            textFieldControllerName.stringValue = settings.name ?? ""
            
            buttonShortcuts1Keys1.keys = settings.shortcuts.rotation[.clockwise]!.keys
            buttonShortcuts1Keys1.updateTitle()
            buttonShortcuts1Keys2.keys = settings.shortcuts.rotation[.counterclockwise]!.keys
            buttonShortcuts1Keys2.updateTitle()
            
            buttonShortcuts2Keys1.keys = settings.shortcuts.pressedRotation[.clockwise]!.keys
            buttonShortcuts2Keys1.updateTitle()
            buttonShortcuts2Keys2.keys = settings.shortcuts.pressedRotation[.counterclockwise]!.keys
            buttonShortcuts2Keys2.updateTitle()
            
            buttonShortcuts3Keys1.keys = settings.shortcuts.single.keys
            buttonShortcuts3Keys1.updateTitle()
            buttonShortcuts3Keys2.keys = settings.shortcuts.double.keys
            buttonShortcuts3Keys2.updateTitle()
            
            switchHaptics.flag = settings.haptics
            switchPhysicalDirection.flag = settings.physicalDirection
            switchAlternativeDirection.flag = settings.alternativeDirection
            
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
        }
        
        refreshControllersMenuManager()
        
        for (index, item) in popUpButtonControllerSelector.itemArray.enumerated() {
            if
                let controller = item.representedObject as? Controller,
                controller.id == Controllers.selectedController.id
            { popUpButtonControllerSelector.selectItem(at: index) }
            
        }
    }
    
}

extension ControllersViewController: DialRotationTypeMenuDelegate {
    
    func setRotationType(_ sender: Any?) {
        guard let item = sender as? MenuOptionItem<Rotation.RawType> else { return }
        
        Controllers.selectedSettings?.rotationType = item.option
        rotationTypeMenuItems?.updateRotationTypeOptions(item.option)
    }
    
}

extension ControllersViewController: DialModifiersMenuDelegate {
    
    func setModifiers(_ sender: Any?) {
        guard let option = sender as? ModifiersOptionItem else { return }
        
        Controllers.selectedSettings?.shortcuts.setModifiersFor(
            option.actionTarget,
            modifiers: option.option,
            activated: option.flag
        )
        modifiersMenuItemsArray
            .filter { $0.key == option.actionTarget }
            .forEach { $0.value.updateModifierOptions(Controllers.selectedSettings?.shortcuts.getModifiersFor(option.actionTarget) ?? []) }
    }
    
}

extension ControllersViewController {
    
    // MARK: - Leading controls
    
    @IBAction func switchCollapsedSegment(_ sender: NSSegmentedControl) {
        let index = sender.indexOfSelectedItem
        if index == 2 {
            updateSegment(.advanced)
        } else if let nextSegment = Segment(rawValue: index) {
            updateSegment(nextSegment)
        }
    }
    
    @IBAction func switchExpandedSegment(_ sender: NSSegmentedControl) {
        if let nextSegment = Segment(rawValue: sender.indexOfSelectedItem + 2) {
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
