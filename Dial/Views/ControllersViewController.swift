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

extension NSUserInterfaceItemIdentifier {
    
    static let activatedControllersColumn = NSUserInterfaceItemIdentifier("ActivatedControllersColumn")
    
}

class ControllersViewController: NSViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var panelRight: NSBox!
    
    @IBOutlet weak var viewSettings: NSStackView!
    
    @IBOutlet weak var viewHeader: NSStackView!
    
    @IBOutlet weak var viewBody: NSStackView!
    
    
    
    @IBOutlet weak var viewControllerName: NSStackView!
    
    @IBOutlet weak var viewSegmentedControls: NSStackView!
    
    @IBOutlet weak var viewDefaultControllerLabels: NSStackView!
    
    
    
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
    
    @IBOutlet weak var scrollViewActivatedControllers: NSScrollView!
    
    @IBOutlet weak var tableViewActivatedControllers: ActivatedControllersTableView!
    
    
    
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
    
    
    
    private lazy var activatedControllersDataSource: ActivatedControllersDataSource = .init(tableView: tableViewActivatedControllers) { (tableView, cell, row, item) -> NSView in
        guard
            let cell = tableView.makeView(withIdentifier: .activatedControllersColumn, owner: self) as? ActivatedControllerCell,
            let controller = Controllers.fetch(item)
        else { return .init() }
        
        cell.set(controller)
        return cell
    }
    
    private let activatedControllersSection = "ActivatedControllersSection"
    
}

extension ControllersViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rotationTypeMenuItems = .init(delegate: self)
        
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
        iconChooserViewController.chooseIconHandler = self
        
        rotationTypeMenuManager = .init(delegate: self) { [MenuManager.groupItems(rotationTypeMenuItems!.rotationTypeOptions)] }
        popUpButtonRotationType.menu = rotationTypeMenuManager?.menu
        
        Task { @MainActor in
            for await _ in Defaults.updates([.selectedControllerID, .shortcutsControllerSettings]) {
                updateSelectedController(Controllers.selectedController)
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.currentControllerID, .activatedControllerIDs]) {
                updateActivatedControllers(Controllers.activatedControllers)
            }
        }
        
        tableViewActivatedControllers.rowHeight = 42
        tableViewActivatedControllers.dataSource = activatedControllersDataSource
        tableViewActivatedControllers.registerForDraggedTypes([ControllerID.pasteboardType])
        
        var snapshot = NSDiffableDataSourceSnapshot<String, ControllerID>()
        snapshot.appendSections([activatedControllersSection])
        snapshot.appendItems(Defaults[.activatedControllerIDs], toSection: activatedControllersSection)
        activatedControllersDataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension ControllersViewController {
    
    override func viewDidLayout() {
        let headerSpacing = 8.0
        let bodySpacing = 20.0
        let settingsSpacing = 20.0
        let gap = 34.0
        
        let currentHeight = panelRight.bounds.height
        let availableHeight = currentHeight - gap
        
        let nameHeight = viewControllerName.bounds.height
        let segmentedControlHeight = segmentedControlCollapsed.bounds.height
        
        let shortcutsHeight = viewShortcuts1_1.bounds.height + viewShortcuts1_2.bounds.height + bodySpacing
        let optionsHeight = viewOptions.bounds.height
        let separatorHeight = separatorShortcuts1Shortcuts2.bounds.height
        
        let collapsedMaxHeight = (nameHeight + segmentedControlHeight + headerSpacing) + (shortcutsHeight * 3 + separatorHeight * 2 + bodySpacing * 4) + settingsSpacing
        let expandedMaxHeight = (nameHeight) + (shortcutsHeight * 3 + optionsHeight + separatorHeight * 3 + bodySpacing * 6) + settingsSpacing
        
        if availableHeight > expandedMaxHeight {
            updateEnabledSegmentedControl(.none)
            updateSegment(nil)
        } else if availableHeight > collapsedMaxHeight {
            updateEnabledSegmentedControl(.expanded)
            updateSegment(segmentExpanded)
        } else {
            updateEnabledSegmentedControl(.collapsed)
            updateSegment(segmentCollapsed)
        }
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
    
    func runFastAnimation(_ execute: () -> Void) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            
            execute()
        }
    }
    
    func toggleViewVisibilityWithTransition(_ view: NSView, isHidden: Bool) {
        guard view.isHidden != isHidden else { return }
        runFastAnimation {
            view.isHidden = isHidden
            view.animator().alphaValue = isHidden ? 0 : 1
        }
    }
    
    func onDataSourceSnapshot<S, I>(
        _ dataSource: NSTableViewDiffableDataSource<S, I>,
        snapshotOperation: (inout NSDiffableDataSourceSnapshot<S, I>) -> Void,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = dataSource.snapshot()
        snapshotOperation(&snapshot)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    func updateEnabledSegmentedControl(_ enabledSegmentedControl: EnabledSegmentedControl) {
        self.enabledSegmentedControl = enabledSegmentedControl
        
        switch enabledSegmentedControl {
        case .collapsed:
            toggleViewVisibilityWithTransition(segmentedControlCollapsed, isHidden: false)
            toggleViewVisibilityWithTransition(segmentedControlExpanded, isHidden: true)
        case .expanded:
            toggleViewVisibilityWithTransition(segmentedControlCollapsed, isHidden: true)
            toggleViewVisibilityWithTransition(segmentedControlExpanded, isHidden: false)
        case .none:
            segmentedControlCollapsed.isHidden = true
            segmentedControlExpanded.isHidden = true
        }
    }
    
    func updateSegment(_ segment: Segment?) {
        if let segment {
            switch segment {
            case .dialing:
                toggleViewVisibilityWithTransition(viewShortcuts1_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts1_2, isHidden: false)
                
                toggleViewVisibilityWithTransition(separatorShortcuts1Shortcuts2, isHidden: false)
                
                toggleViewVisibilityWithTransition(viewShortcuts2_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts2_2, isHidden: false)
                
                separatorShortcuts2Shortcuts3.isHidden = true
                
                viewShortcuts3_1.isHidden = true
                viewShortcuts3_2.isHidden = true
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = true
            case .pressing:
                viewShortcuts1_1.isHidden = true
                viewShortcuts1_2.isHidden = true
                
                separatorShortcuts1Shortcuts2.isHidden = true
                
                toggleViewVisibilityWithTransition(viewShortcuts2_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts2_2, isHidden: false)
                
                toggleViewVisibilityWithTransition(separatorShortcuts2Shortcuts3, isHidden: false)
                
                toggleViewVisibilityWithTransition(viewShortcuts3_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts3_2, isHidden: false)
                
                separatorShortcuts3Options.isHidden = true
                
                viewOptions.isHidden = true
            case .shortcuts:
                toggleViewVisibilityWithTransition(viewShortcuts1_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts1_2, isHidden: false)
                
                toggleViewVisibilityWithTransition(separatorShortcuts1Shortcuts2, isHidden: false)
                
                toggleViewVisibilityWithTransition(viewShortcuts2_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts2_2, isHidden: false)
                
                toggleViewVisibilityWithTransition(separatorShortcuts2Shortcuts3, isHidden: false)
                
                toggleViewVisibilityWithTransition(viewShortcuts3_1, isHidden: false)
                toggleViewVisibilityWithTransition(viewShortcuts3_2, isHidden: false)
                
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
                
                toggleViewVisibilityWithTransition(viewOptions, isHidden: false)
            }
        } else {
            // Shows all
            
            toggleViewVisibilityWithTransition(viewShortcuts1_1, isHidden: false)
            toggleViewVisibilityWithTransition(viewShortcuts1_2, isHidden: false)
            
            toggleViewVisibilityWithTransition(separatorShortcuts1Shortcuts2, isHidden: false)
            
            toggleViewVisibilityWithTransition(viewShortcuts2_1, isHidden: false)
            toggleViewVisibilityWithTransition(viewShortcuts2_2, isHidden: false)
            
            toggleViewVisibilityWithTransition(separatorShortcuts2Shortcuts3, isHidden: false)
            
            toggleViewVisibilityWithTransition(viewShortcuts3_1, isHidden: false)
            toggleViewVisibilityWithTransition(viewShortcuts3_2, isHidden: false)
            
            toggleViewVisibilityWithTransition(viewOptions, isHidden: false)
        }
    }
    
    func updateActivatedControllers(_ controllers: [Controller]) {
        refreshControllersMenuManager()
    }
    
    func updateSelectedController(_ controller: Controller) {
        let canDeactivate = Controllers.activatedControllers.count > 1
        let canActivate = Controllers.activatedControllers.count < Defaults[.maxControllerCount]
        
        let activated = Controllers.activatedControllers.contains(where: { $0.id == controller.id })
        switchControllerActivated.animator().flag = activated
        switchControllerActivated.animator().isEnabled = (activated && canDeactivate) || (!activated && canActivate)
        
        refreshControllersMenuManager()
        for (index, item) in popUpButtonControllerSelector.itemArray.enumerated() {
            if
                let controller = item.representedObject as? Controller,
                controller.id == Controllers.selectedController.id
            { popUpButtonControllerSelector.selectItem(at: index) }
        }
        
        updateSettings(controller)
        
        tableViewActivatedControllers.reloadData()
    }
    
    func updateSettings(_ controller: Controller) {
        if let defaultController = controller as? DefaultController {
            labelDefaultControllerDescription.stringValue = defaultController.description
            
            viewDefaultControllerLabels.isHidden = false
            viewControllerName.isHidden = true
            viewSegmentedControls.isHidden = true
            viewBody.isHidden = true
            
            segmentedControlAddOrDeleteController.setEnabled(false, forSegment: 0)
            segmentedControlResetController.isEnabled = false
            
            iconChooserViewController.setAll(false)
        }
        
        else if let shortcutsController = controller as? ShortcutsController {
            let settings = shortcutsController.settings
            
            viewDefaultControllerLabels.isHidden = true
            viewControllerName.isHidden = false
            viewSegmentedControls.isHidden = false
            viewBody.isHidden = false
            
            segmentedControlAddOrDeleteController.setEnabled(true, forSegment: 0)
            segmentedControlResetController.isEnabled = true
            
            textFieldControllerName.stringValue = settings.name ?? ""
            
            updateModifiers(segmentedControlShortcuts1Modifiers1, modifiers: settings.shortcuts.getModifiers(.rotateClockwise))
            updateModifiers(segmentedControlShortcuts1Modifiers2, modifiers: settings.shortcuts.getModifiers(.rotateCounterclockwise))
            
            updateModifiers(segmentedControlShortcuts2Modifiers1, modifiers: settings.shortcuts.getModifiers(.pressedRotateClockwise))
            updateModifiers(segmentedControlShortcuts2Modifiers2, modifiers: settings.shortcuts.getModifiers(.pressedRotateCounterclockwise))
            
            updateModifiers(segmentedControlShortcuts3Modifiers1, modifiers: settings.shortcuts.getModifiers(.clickSingle))
            updateModifiers(segmentedControlShortcuts3Modifiers2, modifiers: settings.shortcuts.getModifiers(.clickDouble))
            
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
    }
    
    func getModifiers(_ segmentedControl: NSSegmentedControl) -> NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        
        if segmentedControl.isSelected(forSegment: 0) {
            modifiers.formUnion(.shift)
        }
        
        if segmentedControl.isSelected(forSegment: 1) {
            modifiers.formUnion(.control)
        }
        
        if segmentedControl.isSelected(forSegment: 2) {
            modifiers.formUnion(.option)
        }
        
        if segmentedControl.isSelected(forSegment: 3) {
            modifiers.formUnion(.command)
        }
        
        return modifiers
    }
    
    func updateModifiers(_ segmentedControl: NSSegmentedControl, modifiers: NSEvent.ModifierFlags) {
        segmentedControl.animator().setSelected(modifiers.contains(.shift), forSegment: 0)
        segmentedControl.animator().setSelected(modifiers.contains(.control), forSegment: 1)
        segmentedControl.animator().setSelected(modifiers.contains(.option), forSegment: 2)
        segmentedControl.animator().setSelected(modifiers.contains(.command), forSegment: 3)
    }
    
}

extension ControllersViewController: DialControllerMenuDelegate {
    
    func setController(_ sender: Any?) {
        guard let item = sender as? ControllerOptionItem else { return }
                
        let controller = item.option
        Controllers.selectedController = controller
    }
    
}

extension ControllersViewController: DialRotationTypeMenuDelegate {
    
    func setRotationType(_ sender: Any?) {
        guard let item = sender as? MenuOptionItem<Rotation.RawType> else { return }
        
        Controllers.selectedSettings?.rotationType = item.option
        rotationTypeMenuItems?.updateRotationTypeOptions(item.option)
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
        // Set activated or not
        
        let activated = sender.flag
        let controller = Controllers.selectedController
        Controllers.toggle(activated, controller: controller)
        
        onDataSourceSnapshot(activatedControllersDataSource) { snapshot in
            if activated {
                snapshot.appendItems([controller.id], toSection: activatedControllersSection)
            } else {
                snapshot.deleteItems([controller.id])
            }
        }
    }
    
    @IBAction func addOrDeleteController(_ sender: NSSegmentedControl) {
        let index = sender.indexOfSelectedItem
        if index == 0 {
            // Delete
            
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
            
            onDataSourceSnapshot(activatedControllersDataSource) { snapshot in
                snapshot.deleteItems([selectedController.id])
            }
        } else if index == 1 {
            // Add
            
            let controller = Controllers.append()
            
            Controllers.selectedController = controller
            Controllers.toggle(true, controller: controller)
            
            onDataSourceSnapshot(activatedControllersDataSource) { snapshot in
                snapshot.appendItems([controller.id], toSection: activatedControllersSection)
            }
        }
    }
    
    @IBAction func resetController(_ sender: NSSegmentedControl) {
        guard Controllers.selectedController is ShortcutsController else { return }
        
        if let settings = Controllers.selectedSettings, settings.shortcuts.isEmpty {
            Controllers.selectedSettings?.reset(resetsName: true, resetsIcon: true)
        } else {
            Controllers.selectedSettings?.reset()
        }
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
    
    @IBAction func toggleShortcutsModifiers(_ sender: NSSegmentedControl) {
        let modifiers = getModifiers(sender)
        
        if sender == segmentedControlShortcuts1Modifiers1 {
            Controllers.selectedSettings?.shortcuts.rotation[.clockwise]?.modifiers = modifiers
        }
        
        if sender == segmentedControlShortcuts1Modifiers2 {
            Controllers.selectedSettings?.shortcuts.rotation[.counterclockwise]?.modifiers = modifiers
        }
        
        if sender == segmentedControlShortcuts2Modifiers1 {
            Controllers.selectedSettings?.shortcuts.pressedRotation[.clockwise]?.modifiers = modifiers
        }
        
        if sender == segmentedControlShortcuts2Modifiers2 {
            Controllers.selectedSettings?.shortcuts.pressedRotation[.counterclockwise]?.modifiers = modifiers
        }
        
        if sender == segmentedControlShortcuts3Modifiers1 {
            Controllers.selectedSettings?.shortcuts.single.modifiers = modifiers
        }
        
        if sender == segmentedControlShortcuts3Modifiers2 {
            Controllers.selectedSettings?.shortcuts.double.modifiers = modifiers
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
