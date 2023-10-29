//
//  WindowController.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation
import AppKit

extension NSImage {
    
    static func mask(withCornerRadius radius: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: radius * 2, height: radius * 2), flipped: false) {
            NSBezierPath(roundedRect: $0, xRadius: radius, yRadius: radius).fill()
            NSColor.black.set()
            return true
        }
        
        image.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
        image.resizingMode = .stretch
        
        return image
    }
    
}

class DialWindow: NSWindow {
    
    private static var menuAppearanceObservation: NSKeyValueObservation?
    
    override var canBecomeKey: Bool {
        true
    }
    
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        hasShadow = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        level = .floating
        collectionBehavior = .canJoinAllSpaces
        backgroundColor = .clear
        
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil
        )
        
        let identifier = NSStoryboard.SceneIdentifier("WindowController")
        
        guard let controller = storyboard.instantiateController(
            withIdentifier: identifier
        ) as? WindowController else {
            fatalError("Can not find WindowController")
        }
        
        // Observe appearance change
        DialWindow.menuAppearanceObservation = NSApp.observe(\.effectiveAppearance) { (app, _) in
            app.effectiveAppearance.performAsCurrentDrawingAppearance {
                let windowController = ((app.delegate as? AppDelegate)?.dialWindow?.contentViewController as? WindowController)
                
                if windowController?.isViewLoaded ?? false {
                    windowController?.updateColoredWidgets()
                }
            }
        }
        
        contentViewController = controller
        
        
        
        let visualEffectView = NSVisualEffectView(frame: self.contentView!.bounds)
        
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .popover
        visualEffectView.maskImage = NSImage.mask(withCornerRadius: 16)
        
        self.contentView?.addSubview(visualEffectView, positioned: .below, relativeTo: nil)
    }
    
    func show() {
        (contentViewController as? WindowController)?.updateColoredWidgets()
        makeKeyAndOrderFront(nil)
        updatePosition()
    }
    
    func hide() {
        close()
    }
    
    func updatePosition(_ animate: Bool = false) {
        guard
            let screenSize = NSScreen.main?.frame.size,
            let screenOrigin = NSScreen.main?.frame.origin,
            let stackView = (contentViewController as? WindowController)?.stackView
        else {
            center()
            return
        }
        
        let enabledSubview = stackView.subviews[Data.dialMode.rawValue]
        
        let mouseLocation = NSEvent.mouseLocation
        let frameSize = frame.size
        let frameOrigin = frame.origin
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
    }
    
}

class WindowController: NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    
    func updateColoredWidgets() {
        stackView.subviews.forEach {
            updateSubview($0)
        }
    }
    
    func updateSubview(_ subview: NSView) {
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
    }
    
}
