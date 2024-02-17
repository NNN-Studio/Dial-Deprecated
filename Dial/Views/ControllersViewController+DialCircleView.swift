//
//  DialCircleViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/17.
//

import Foundation
import AppKit
import Defaults

extension ControllersViewController {
    
    func loadDialCircleViewInto(_ superview: NSView) {
        let backgroundView = NSVisualEffectView()
        superview.addSubview(backgroundView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.blendingMode = .behindWindow
        backgroundView.material = .contentBackground
        
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = superview.frame.size.height / 2
        backgroundView.state = .active
        
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalTo: superview.widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: superview.heightAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
        
        let radiansMultiplier = 1.35
        
        let iconsView = NSView()
        iconsView.translatesAutoresizingMaskIntoConstraints = false
        layerSubview(superview, iconsView)
        
        func updateIconViews() {
            for (index, iconView) in iconsView.subviews.compactMap({ $0 as? NSImageView }).enumerated() {
                if index == Controllers.activatedIndexOf(Controllers.currentController) {
                    iconView.contentTintColor = .controlAccentColor
                } else {
                    iconView.contentTintColor = nil
                }
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.activatedControllerIDs, .shortcutsControllerSettings]) {
                iconsView.subviews.filter({ $0 is NSImageView }).forEach({ $0.removeFromSuperview() })
                
                Controllers.activatedControllers
                    .enumerated()
                    .forEach {
                        let index = $0.offset
                        let radians = getRadians(ofIndex: index)
                        let radius = superview.frame.height / 4.0 * radiansMultiplier
                        let pos = NSPoint(x: radius * sin(-radians - Double.pi), y: radius * cos(radians - Double.pi))
                        
                        let iconView = NSImageView(image: $0.element.representingSymbol.image.withSymbolConfiguration(.init(
                            pointSize: superview.frame.height / 4 * 0.3,
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
        
        let buttonsView = NSView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        layerSubview(superview, buttonsView)
        
        func updateButtons() {
            for (index, button) in buttonsView.subviews.compactMap({ $0 as? NSButton }).enumerated() {
                button.isHidden = index >= Controllers.activatedControllers.count
                
                if index == Controllers.activatedIndexOf(Controllers.currentController) {
                    button.showsBorderOnlyWhileMouseInside = false
                } else {
                    button.showsBorderOnlyWhileMouseInside = true
                }
            }
        }
        
        for index in 0..<Defaults[.maxControllerCount] {
            let radians = self.getRadians(ofIndex: index)
            let radius = superview.frame.height / 4.0 * radiansMultiplier * 0.99
            let pos = NSPoint(x: radius * sin(-radians - Double.pi), y: radius * cos(radians - Double.pi))
            let size = superview.frame.height / 4 * 0.65
            
            let button = NSButton()
            buttonsView.addSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.target = self
            button.action = #selector(self.dialCircleSelectController(_:))
            
            button.title = ""
            button.bezelStyle = .badge
            button.showsBorderOnlyWhileMouseInside = true
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: size),
                button.heightAnchor.constraint(equalToConstant: size),
                button.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor, constant: pos.x),
                button.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor, constant: pos.y)
            ])
        }
        
        let indicatorsView = NSView()
        indicatorsView.translatesAutoresizingMaskIntoConstraints = false
        layerSubview(superview, indicatorsView)
        
        func updateIndicators() {
            for (index, indicator) in indicatorsView.subviews.enumerated() {
                if index == Controllers.activatedIndexOf(Controllers.currentController) {
                    indicator.isHidden = false
                } else {
                    indicator.isHidden = true
                }
            }
        }
        
        for index in 0..<Defaults[.maxControllerCount] {
            let radians = self.getRadians(ofIndex: index)
            let radius = superview.frame.height / 4.0 * radiansMultiplier * 1.35
            let pos = NSPoint(x: radius * sin(-radians - Double.pi), y: radius * cos(radians - Double.pi))
            let size = 7.5
            
            let indicator = NSBox()
            indicatorsView.addSubview(indicator)
            
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.contentView?.translatesAutoresizingMaskIntoConstraints = false // Toxic
            indicator.boxType = .custom
            indicator.titlePosition = .noTitle
            
            indicator.borderWidth = 0
            indicator.cornerRadius = size / 2
            indicator.fillColor = .controlAccentColor
            
            NSLayoutConstraint.activate([
                indicator.widthAnchor.constraint(equalToConstant: size),
                indicator.heightAnchor.constraint(equalToConstant: size),
                indicator.centerXAnchor.constraint(equalTo: indicatorsView.centerXAnchor, constant: pos.x),
                indicator.centerYAnchor.constraint(equalTo: indicatorsView.centerYAnchor, constant: pos.y)
            ])
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.selectedControllerID) {
                updateIconViews()
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates([.activatedControllerIDs, .selectedControllerID]) {
                updateButtons()
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.currentControllerID) {
                updateIndicators()
            }
        }
    }
    
    private func layerSubview(
        _ superview: NSView,
        _ view: NSView
    ) {
        superview.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            view.topAnchor.constraint(equalTo: superview.topAnchor),
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    private func getRadians(
        ofIndex index: Int = Controllers.activatedIndexOf(Controllers.currentController) ?? 0
    ) -> CGFloat {
        CGFloat(index % Defaults[.maxControllerCount]) / CGFloat(Defaults[.maxControllerCount]) * 2.0 * Double.pi
    }
    
}

extension ControllersViewController {
    
    @objc func dialCircleSelectController(_ sender: Any?) {
        guard let button = sender as? NSButton else { return }
        guard 
            let index = button.superview?.subviews.filter({ $0 is NSButton }).firstIndex(of: button),
            index < Controllers.activatedControllers.count
        else { return }
        
        Controllers.selectedController = Controllers.activatedControllers[index]
    }
    
}
