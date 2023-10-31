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
    
    
    
    let dialView = DialView()
    
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
        self.contentView = dialView
        
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
                self.dialView.updateColoredWidgets()
            }
        }
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.makeKeyAndOrderFront(nil)
            self.dialView.updateColoredWidgets()
            self.updatePosition()
        }
    }
    
    func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.close()
        }
    }
    
    func updatePosition(_ animate: Bool = false) {
        /*
        guard
            let screenSize = NSScreen.main?.frame.size,
            let screenOrigin = NSScreen.main?.frame.origin,
            let stackView = dialViewController?.stackView
        else {
            center()
            return
        }
        
        let enabledSubview = stackView.subviews[Data.dialMode.rawValue]
        
        let mouseLocation = NSEvent.mouseLocation
        let frameSize = frame.size
        let offset = enabledSubview.frame.origin.applying(CGAffineTransform(
            translationX: stackView.frame.origin.x + enabledSubview.frame.width / 2,
            y: stackView.frame.origin.y + enabledSubview.frame.height / 2
        ))
        
        let translatedFrameOrigin = mouseLocation
            .applying(CGAffineTransform(translationX: -screenOrigin.x, y: -screenOrigin.y))
            .applying(CGAffineTransform(translationX: -offset.x, y: -offset.y))
        let clampedFrameOrigin = CGPoint(
            x: screenOrigin.x + max(0, min(screenSize.width - frameSize.width, translatedFrameOrigin.x)),
            y: screenOrigin.y + max(0, min(screenSize.height - frameSize.height, translatedFrameOrigin.y))
        )
        
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = animate
            
            setFrameOrigin(clampedFrameOrigin)
        }
         */
    }
    
}

class DialView: NSView {
    
    var backgrounds: (outer: NSVisualEffectView?, inner: NSVisualEffectView?)
    
    override func viewDidUnhide() {
        backgrounds.outer = createVisualEffectView(size: DialWindow.size.outer, material: .fullScreenUI)
        addSubview(backgrounds.outer!, positioned: .above, relativeTo: nil)
        
        backgrounds.inner = createVisualEffectView(size: DialWindow.size.inner, material: .sheet)
        addSubview(backgrounds.inner!, positioned: .above, relativeTo: nil)
    }
    
    private func createVisualEffectView(
        size: CGFloat,
        blendMode: NSVisualEffectView.BlendingMode = .behindWindow,
        material: NSVisualEffectView.Material
    ) -> NSVisualEffectView {
        let frameRect = bounds
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
    
    func updateColoredWidgets() {
    }
    
}
