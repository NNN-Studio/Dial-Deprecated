//
//  DialWindow.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation
import AppKit

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
        
        level = .floating
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
        
        
        
        self.contentView?.addSubview(createVisualEffectView(size: DialWindow.size.inner, material: .sheet), positioned: .below, relativeTo: nil)
        self.contentView?.addSubview(createVisualEffectView(size: DialWindow.size.outer, material: .fullScreenUI), positioned: .below, relativeTo: nil)
    }
    
    private func createVisualEffectView(
        size: CGFloat,
        blendMode: NSVisualEffectView.BlendingMode = .behindWindow,
        material: NSVisualEffectView.Material
    ) -> NSVisualEffectView {
        let frameRect = contentView!.bounds
        let sizeRect = NSRect(origin: .zero, size: NSSize(width: size, height: size))
        let view = NSVisualEffectView(frame: sizeRect.applying(CGAffineTransform(
            translationX: frameRect.minX + (frameRect.width - size) / 2,
            y: frameRect.minY + (frameRect.height - size) / 2
        )))
        
        view.blendingMode = blendMode
        view.material = material
        
        view.wantsLayer = true
        view.layer?.cornerRadius = size / 2
        view.state = .active
        
        return view
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.makeKeyAndOrderFront(nil)
            self.dialViewController?.updateColoredWidgets()
            self.updatePosition()
        }
    }
    
    func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.close()
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
        let clampedFrameOrigin = CGPoint(
            x: screenOrigin.x + max(0, min(screenSize.width - frameSize.width, translatedFrameOrigin.x)),
            y: screenOrigin.y + max(0, min(screenSize.height - frameSize.height, translatedFrameOrigin.y))
        )
        
        setFrameOrigin(clampedFrameOrigin)
    }
    
}

class DialViewController: NSViewController {
    
    func updateColoredWidgets() {
    }
    
    func updateSubview(_ subview: NSView) {
        /*
        let index = stackView.subviews.firstIndex(of: subview)
        let enabled = Data.dialMode.rawValue == index
        
        if let box = subview as? NSBox {
            box.animator().borderColor = .clear
            box.animator().fillColor = .controlAccentColor.withAlphaComponent(0.2)
            box.animator().isTransparent = !enabled
            
            box.subviews.forEach {
                $0.subviews.forEach {
                    if let imageView = $0 as? NSImageView {
                        imageView.animator().contentTintColor = enabled ? .controlAccentColor : .secondaryLabelColor
                    }
                }
            }
        }
         */
    }
    
}
