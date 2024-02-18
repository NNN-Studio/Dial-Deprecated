//
//  DialWindow.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation
import AppKit
import Defaults
import SFSafeSymbols

extension NSView {
    
    func setRotation(
        _ radians: CGFloat,
        animated: Bool = false,
        duration: TimeInterval = 0.2
    ) {
        if let layer, let animatorLayer = animator().layer {
            layer.position = CGPoint(x: frame.midX, y: frame.midY)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let transform = CATransform3DMakeRotation(radians, 0, 0, 1)
            
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    context.duration = duration
                    
                    animatorLayer.transform = transform
                }
            } else {
                layer.transform = transform
            }
        }
    }
    
    func setScale(
        _ scale: CGFloat,
        animated: Bool = false,
        duration: TimeInterval = 0.2
    ) {
        if let layer, let animatorLayer = animator().layer {
            layer.position = CGPoint(x: frame.midX, y: frame.midY)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let transform = CATransform3DMakeScale(scale, scale, 0)
            
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    context.duration = duration
                    
                    animatorLayer.transform = transform
                }
            } else {
                layer.transform = transform
            }
        }
    }
    
}

class DialWindow: NSWindow {
    
    static let diameters = (outer: 340.0, inner: 220.0)
    
    var dialViewController: DialViewController? {
        contentViewController as? DialViewController
    }
    
    override var canBecomeKey: Bool {
        true
    }
    
    init(
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: .zero, styleMask: style, backing: backingStoreType, defer: flag)
        self.contentViewController = DialViewController()
        
        hasShadow = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        ignoresMouseEvents = true
        
        level = .screenSaver
        animationBehavior = .utilityWindow
        collectionBehavior = .canJoinAllSpaces
        backgroundColor = .clear
    }
    
    func show() {
        dialViewController?.showDetails = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.makeKeyAndOrderFront(nil)
            self.updatePosition()
        }
    }
    
    func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dialViewController?.showDetails = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.close()
            }
        }
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    func updatePosition() {
        guard
            let screenSize = NSScreen.main?.frame.size,
            let screenOrigin = NSScreen.main?.frame.origin
        else {
            center()
            return
        }
        
        let mouseLocation = NSEvent.mouseLocation
        let frameSize = frame.size
        
        let translatedFrameOrigin = mouseLocation
            .applying(CGAffineTransform(translationX: -screenOrigin.x, y: -screenOrigin.y))
            .applying(CGAffineTransform(translationX: -frameSize.width / 2, y: -frameSize.height / 2))
        let translatedScreenOrigin = screenOrigin.applying(CGAffineTransform(translationX: -frameSize.width / 2, y: -frameSize.height / 2))
        var clampedFrameOrigin = CGPoint(
            x: screenOrigin.x + max(0, min(screenSize.width - frameSize.width, translatedFrameOrigin.x)),
            y: screenOrigin.y + max(0, min(screenSize.height - frameSize.height, translatedFrameOrigin.y))
        )
        
        let reached = (
            minX: translatedFrameOrigin.x <= screenOrigin.x,
            minY: translatedFrameOrigin.y <= screenOrigin.y,
            maxX: translatedFrameOrigin.x + frameSize.width >= screenOrigin.x + screenSize.width,
            maxY: translatedFrameOrigin.y + frameSize.height >= screenOrigin.y + screenSize.height
        )
        let offset: CGFloat = (DialWindow.diameters.inner / 2) / sqrt(2)
        
        if reached.minX {
            if reached.minY {
                // Left bottom corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: offset, y: offset))
                
                dialViewController?.radiansOffset = -Double.pi / 4
                dialViewController?.iconDirection = .upper
            } else if reached.maxY {
                // Left top corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: offset, y: -offset))
                    .applying(CGAffineTransform(translationX: 0, y: screenSize.height))
                
                dialViewController?.radiansOffset = -Double.pi / 4 * 3
                dialViewController?.iconDirection = .lower
            } else {
                // Left edge
                clampedFrameOrigin.x = translatedScreenOrigin.x + offset
                
                dialViewController?.radiansOffset = -Double.pi / 2
                dialViewController?.iconDirection = .right
            }
        } else if reached.maxX {
            if reached.minY {
                // Right bottom corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: -offset, y: offset))
                    .applying(CGAffineTransform(translationX: screenSize.width, y: 0))
                
                dialViewController?.radiansOffset = Double.pi / 4
                dialViewController?.iconDirection = .upper
            } else if reached.maxY {
                // Right top corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: -offset, y: -offset))
                    .applying(CGAffineTransform(translationX: screenSize.width, y: screenSize.height))
                
                dialViewController?.radiansOffset = Double.pi / 4 * 3
                dialViewController?.iconDirection = .lower
            } else {
                // Right edge
                clampedFrameOrigin.x = translatedScreenOrigin.x + screenSize.width - offset
                
                dialViewController?.radiansOffset = Double.pi / 2
                dialViewController?.iconDirection = .left
            }
        } else if reached.minY {
            // Bottom edge
            clampedFrameOrigin.y = translatedScreenOrigin.y + offset
            
            dialViewController?.iconDirection = .upper
        } else if reached.maxY {
            // Top edge
            clampedFrameOrigin.y = translatedScreenOrigin.y + screenSize.height - offset
            
            dialViewController?.iconDirection = .lower
        } else {
            // Normal
            dialViewController?.radiansOffset = 0
            dialViewController?.iconDirection = .upper
        }
        
        setFrameOrigin(clampedFrameOrigin)
    }
    
}

@Observable class DialViewController: NSViewController {
    
    var radiansOffset = CGFloat.zero
    
    var showDetails = true
    
    var iconDirection: IconDirection = .upper
    
    private var titleCache = ""
    
    private var titleImageCache: NSImage?
    
    enum IconDirection {
        
        case left
        
        case right
        
        case upper
        
        case lower
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentView = NSView()
        
        parentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            parentView.widthAnchor.constraint(equalToConstant: DialWindow.diameters.outer),
            parentView.heightAnchor.constraint(equalToConstant: DialWindow.diameters.outer)
        ])
        
        let foregroundMultiplier = DialWindow.diameters.inner / DialWindow.diameters.outer
        var backgroundViews: [NSView] = []
        var foregroundViews: [NSView] = []
        
        let effect1 = createVisualEffectView(material: .menu)
        backgroundViews.append(effect1)
        fillSubview(
            parentView, effect1
        )
        
        let effect2 = createVisualEffectView(multiplier: foregroundMultiplier * 1.05, material: .hudWindow)
        backgroundViews.append(effect2)
        fillSubview(
            parentView, effect2,
            multiplier: foregroundMultiplier * 1.05
        )
        
        let effect3 = createVisualEffectView(multiplier: foregroundMultiplier, material: .contentBackground)
        foregroundViews.append(effect3)
        fillSubview(
            parentView, effect3,
            multiplier: foregroundMultiplier
        )
        
        let titleView = NSTextField(labelWithString: titleCache)
        parentView.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBezeled = false
        titleView.isEditable = false
        titleView.isSelectable = false
        
        titleView.alignment = .center
        titleView.font = .systemFont(ofSize: DialWindow.diameters.inner * 0.0875, weight: .medium)
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            titleView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
        
        let titleIconView = NSImageView()
        parentView.addSubview(titleIconView)
        
        titleIconView.translatesAutoresizingMaskIntoConstraints = false
        titleIconView.contentTintColor = .tertiaryLabelColor
        titleIconView.image = titleImageCache
        
        let titleIconOffset = DialWindow.diameters.inner / 4
        let titleIconViewConstraints: [IconDirection: [NSLayoutConstraint]] = [
            .left: [
                titleIconView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: -titleIconOffset),
                titleIconView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ],
            .right: [
                titleIconView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: titleIconOffset),
                titleIconView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ],
            .upper: [
                titleIconView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                titleIconView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: -titleIconOffset)
            ],
            .lower: [
                titleIconView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                titleIconView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: titleIconOffset)
            ]
        ]
        
        let iconsView = NSView()
        fillSubview(parentView, iconsView)
        
        func updateIconViews() {
            for (index, iconView) in iconsView.subviews.enumerated() {
                if let iconView = iconView as? NSImageView {
                    if
                        let currentIndex = Controllers.activatedIndexOf(Controllers.currentController),
                        index == currentIndex
                    {
                        iconView.contentTintColor = .controlAccentColor
                        iconView.alphaValue = 1
                        iconView.wantsLayer = true
                    } else {
                        iconView.contentTintColor = .tertiaryLabelColor
                        iconView.alphaValue = 0.8
                    }
                }
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.activatedControllerIDs, .shortcutsControllerSettings]) {
                iconsView.subviews.filter({ $0 is NSImageView }).forEach({ $0.removeFromSuperview() })
                iconsView.wantsLayer = true
                
                Controllers.activatedControllers
                    .enumerated()
                    .forEach {
                        let index = $0.offset
                        let radians = getRadians(ofIndex: index)
                        let radius = CGFloat(DialWindow.diameters.inner + DialWindow.diameters.outer) / 4
                        let pos = NSPoint(x: radius * sin(-radians - Double.pi), y: radius * cos(radians - Double.pi))
                        
                        let iconView = NSImageView(image: $0.element.representingSymbol.image.withSymbolConfiguration(.init(
                            pointSize: (DialWindow.diameters.outer - DialWindow.diameters.inner) / 2 * 0.375,
                            weight: .regular
                        ))!)
                        iconsView.addSubview(iconView)
                        
                        iconView.translatesAutoresizingMaskIntoConstraints = false
                        iconView.rotate(byDegrees: -radians * 180 / Double.pi)
                        
                        NSLayoutConstraint.activate([
                            iconView.centerXAnchor.constraint(equalTo: iconsView.centerXAnchor, constant: pos.x),
                            iconView.centerYAnchor.constraint(equalTo: iconsView.centerYAnchor, constant: pos.y)
                        ])
                    }
                
                updateIconViews()
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.currentControllerID) {
                iconsView.setRotation(getRadians(), animated: true)
                titleIconViewConstraints.values.forEach(NSLayoutConstraint.deactivate(_:))
                NSLayoutConstraint.activate(titleIconViewConstraints[iconDirection]!)
                updateIconViews()
                
                let title = Controllers.currentController.name
                titleView.stringValue = title
                titleCache = title
                
                let image = Controllers.currentController.representingSymbol.image.withSymbolConfiguration(.init(
                    pointSize: DialWindow.diameters.inner * 0.135,
                    weight: .medium
                ))
                titleIconView.image = image
                titleImageCache = image
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ AppDelegate.shared!.dial.device.lastButtonState }) {
                print(value)
                switch value {
                case .pressed:
                    parentView.setScale(0.9, animated: true, duration: 0.1)
                case .released:
                    parentView.setScale(1, animated: true, duration: 0.1)
                }
            }
        }
        
        Task { @MainActor in
            for await _ in observationTrackingStream({ self.radiansOffset }) {
                iconsView.setRotation(getRadians(), animated: false)
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ self.iconDirection }) {
                titleIconViewConstraints.values.forEach(NSLayoutConstraint.deactivate(_:))
                NSLayoutConstraint.activate(titleIconViewConstraints[value]!)
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ self.showDetails }) {
                if value {
                    iconsView.alphaValue = 1
                    backgroundViews.forEach({ $0.alphaValue = 1 })
                    
                    titleView.textColor = .controlAccentColor
                    titleIconView.alphaValue = 0
                } else {
                    iconsView.animator().alphaValue = 0
                    backgroundViews.forEach({ $0.animator().alphaValue = 0.35 })
                    
                    titleView.animator().textColor = .labelColor
                    titleIconView.animator().alphaValue = 1
                }
            }
        }
        
        view = parentView
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setCursorVisibility(false)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        setCursorVisibility(true)
    }
    
    private func createVisualEffectView(
        multiplier: CGFloat = 1,
        blendMode: NSVisualEffectView.BlendingMode = .behindWindow,
        material: NSVisualEffectView.Material
    ) -> NSVisualEffectView {
        let size = DialWindow.diameters.outer * multiplier
        let view = NSVisualEffectView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.blendingMode = blendMode
        view.material = material
        
        view.wantsLayer = true
        view.layer?.cornerRadius = size / 2
        view.state = .active
        
        return view
    }
    
    private func fillSubview(
        _ superview: NSView,
        _ view: NSView,
        multiplier: CGFloat = 1,
        positioned place: NSWindow.OrderingMode = .above,
        relativeTo otherView: NSView? = nil
    ) {
        superview.addSubview(view, positioned: place, relativeTo: otherView)
        
        superview.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: multiplier),
            view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: multiplier),
            view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    private func getRadians(
        ofIndex index: Int = Controllers.activatedIndexOf(Controllers.currentController) ?? 0
    ) -> CGFloat {
        CGFloat(index % Defaults[.maxControllerCount]) / CGFloat(Defaults[.maxControllerCount]) * 2.0 * Double.pi + radiansOffset
    }
    
}
