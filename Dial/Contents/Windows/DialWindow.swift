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
        animated: Bool = false
    ) {
        if let layer, let animatorLayer = animator().layer {
            layer.position = CGPoint(x: frame.midX, y: frame.midY)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let transform = CATransform3DMakeRotation(radians, 0, 0, 1)
            
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    animatorLayer.transform = transform
                }
            } else {
                layer.transform = transform
            }
        }
    }
    
}

class DialWindow: NSWindow {
    
    static let size = (outer: 225.0, inner: 135.0)
    
    
    
    var dialViewController: DialViewController? {
        contentViewController as? DialViewController
    }
    
    private static var menuAppearanceObservation: NSKeyValueObservation?
    
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
        
        // Observe appearance change
        DialWindow.menuAppearanceObservation = NSApp.observe(\.effectiveAppearance) { (app, _) in
            app.effectiveAppearance.performAsCurrentDrawingAppearance {
                if let dialViewController = self.dialViewController, dialViewController.isViewLoaded {
                    dialViewController.updateColoredWidgets()
                }
            }
        }
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.makeKeyAndOrderFront(nil)
            self.dialViewController?.updateColoredWidgets()
            self.updatePosition()
            self.dialViewController?.update()
        }
    }
    
    func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.close()
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
            maxX: translatedFrameOrigin.x + frameSize.width >= screenOrigin.x + screenSize.width
        )
        let offset: CGFloat = (DialWindow.size.inner / 2) / sqrt(2)
        dialViewController?.radiansOffset = 0
        
        if reached.minX {
            if reached.minY {
                // Left bottom corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: offset, y: offset))
                dialViewController?.radiansOffset = -Double.pi / 4
            } else {
                // Left edge
                clampedFrameOrigin.x = translatedScreenOrigin.x
                dialViewController?.radiansOffset = -Double.pi / 2
            }
        } else if reached.maxX {
            if reached.minY {
                // Right bottom corner
                clampedFrameOrigin = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: -offset, y: offset))
                    .applying(CGAffineTransform(translationX: screenSize.width, y: 0))
                dialViewController?.radiansOffset = Double.pi / 4
            } else {
                // Right edge
                clampedFrameOrigin.x = translatedScreenOrigin
                    .applying(CGAffineTransform(translationX: screenSize.width, y: 0)).x
                dialViewController?.radiansOffset = Double.pi / 2
            }
        } else if reached.minY {
            // Bottom edge
            clampedFrameOrigin.y = translatedScreenOrigin.y
        }
        
        setFrameOrigin(clampedFrameOrigin)
    }
    
}

class DialViewController: NSViewController {
    
    var radiansOffset = CGFloat.zero
    
    var visualEffectViews: (background: NSVisualEffectView?, foreground: NSVisualEffectView?)
    
    var iconsView: NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = NSView(frame: NSRect(origin: .zero, size: .init(width: DialWindow.size.outer, height: DialWindow.size.outer)))
        
        let foregroundMultiplier = DialWindow.size.inner / DialWindow.size.outer
        visualEffectViews = (
            background: createVisualEffectView(material: .contentBackground),
            foreground: createVisualEffectView(multiplier: foregroundMultiplier, material: .windowBackground)
        )
        fillView(view, visualEffectViews.background!, positioned: .above, relativeTo: nil)
        fillView(view, visualEffectViews.foreground!, multiplier: foregroundMultiplier, positioned: .above, relativeTo: nil)
        
        Task { @MainActor in
            for await _ in Defaults.updates(.activatedControllerIDs) {
                iconsView?.removeFromSuperview()
                iconsView = NSView()
                iconsView?.wantsLayer = true
                fillView(view, iconsView!)
                
                Controllers.activatedControllers
                    .enumerated()
                    .forEach { createIconView(self.iconsView!, $0.element.representingSymbol, $0.offset) }
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.currentControllerID, .activatedControllerIDs]) {
                update(animated: true)
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateColoredWidgets()
        update()
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
        let size = DialWindow.size.outer * multiplier
        let view = NSVisualEffectView()
        
        view.blendingMode = blendMode
        view.material = material
        
        view.wantsLayer = true
        view.layer?.cornerRadius = size / 2
        view.state = .active
        
        return view
    }
    
    private func createIconView(
        _ superview: NSView,
        _ icon: SFSymbol,
        _ index: Int
    ) {
        let radians = getRadians(ofIndex: index)
        let radius = CGFloat(DialWindow.size.inner + DialWindow.size.outer) / 4
        let pos = NSPoint(x: radius * sin(-radians - Double.pi), y: radius * cos(radians - Double.pi))
        
        let view = NSImageView(image: icon.image)
        superview.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rotate(byDegrees: -radians * 180 / Double.pi)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.iconsView!.centerXAnchor, constant: pos.x),
            view.centerYAnchor.constraint(equalTo: self.iconsView!.centerYAnchor, constant: pos.y)
        ])
    }
    
    private func fillView(
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
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: multiplier),
            view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: multiplier),
            view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func getRadians(
        ofIndex index: Int = Controllers.indexOf(Controllers.currentController)!
    ) -> CGFloat {
        CGFloat(index % Defaults[.maxControllerCount]) / CGFloat(Defaults[.maxControllerCount]) * 2 * Double.pi + radiansOffset
    }
    
    func updateColoredWidgets() {
        if let iconsView {
            for (index, iconView) in iconsView.subviews.enumerated() {
                if let iconView = iconView as? NSImageView {
                    if
                        let currentIndex = Controllers.indexOf(Controllers.currentController),
                        index == currentIndex
                    {
                        iconView.contentTintColor = .controlAccentColor
                        let shadow = NSShadow()
                        
                        shadow.shadowColor = .controlAccentColor
                        shadow.shadowBlurRadius = 7.5
                        
                        iconView.wantsLayer = true
                        iconView.shadow = shadow
                    } else {
                        iconView.contentTintColor = .tertiaryLabelColor
                        iconView.shadow = nil
                    }
                }
            }
        }
    }
    
    func update(animated: Bool = false) {
        iconsView?.setRotation(getRadians(), animated: animated)
        updateColoredWidgets()
    }
    
}

extension DialWindow {
    
    var callback: Callback {
        Callback(self)
    }
    
    struct Callback {
        
        private var window: DialWindow
        
        init(_ window: DialWindow) {
            self.window = window
        }
        
        func update(animated: Bool = false) {
            DispatchQueue.main.async {
                if let viewController = window.dialViewController {
                    viewController.updateColoredWidgets()
                    viewController.update(animated: animated)
                }
            }
        }
        
    }
    
}
