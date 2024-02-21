//
//  IconChooserWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/15.
//

import Foundation
import AppKit
import SFSafeSymbols

protocol ChooseIconHandler {
    
    func chooseIcon(_ icon: SFSymbol)
    
}

class IconChooserViewController: NSViewController {
    
    var chooseIconHandler: ChooseIconHandler?
    
    var chosen: SFSymbol = .circleFillableFallback
    
    var scrollView: NSScrollView? {
        view.subviews[0] as? NSScrollView
    }
    
    let columns: Int = 5
    
    let margin: CGFloat = 24
    
    let size: NSSize = .init(width: 355, height: 425)
    
    private var buttons: [NSButton] = []
    
    override func viewDidLoad() {
        buttons = []
        
        let parentView = NSView()
        view = parentView
        
        parentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            parentView.widthAnchor.constraint(equalToConstant: size.width),
            parentView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        
        let indicatorView = NSProgressIndicator()
        parentView.addSubview(indicatorView)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.isIndeterminate = true
        indicatorView.style = .spinning
        indicatorView.startAnimation(nil)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
        
        DispatchQueue.main.async {
            let scrollView = NSScrollView()
            
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = false
            scrollView.drawsBackground = false
            
            let wrapperView = NSView()
            scrollView.documentView = wrapperView
            
            wrapperView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                wrapperView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
                wrapperView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor)
            ])
            
            let vStackView = NSStackView()
            wrapperView.addSubview(vStackView)
            
            vStackView.translatesAutoresizingMaskIntoConstraints = false
            vStackView.orientation = .vertical
            vStackView.spacing = 12
            
            NSLayoutConstraint.activate([
                vStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: self.margin),
                vStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -self.margin),
                vStackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: self.margin),
                vStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -self.margin)
            ])
            
            for (index, icon) in SFSymbol.circleFillableSymbols
                .sorted(by: { $0.rawValue < $1.rawValue })
                .enumerated() {
                let row = index / self.columns
                
                if vStackView.arrangedSubviews.count <= row {
                    let hStackView = NSStackView()
                    vStackView.addArrangedSubview(hStackView)
                    
                    hStackView.translatesAutoresizingMaskIntoConstraints = false
                    hStackView.orientation = .horizontal
                    hStackView.distribution = .fillEqually
                    hStackView.spacing = 12
                    
                    NSLayoutConstraint.activate([
                        hStackView.heightAnchor.constraint(equalToConstant: 37.5),
                        hStackView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
                        hStackView.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
                    ])
                }
                
                let hStackView = vStackView.arrangedSubviews[row] as! NSStackView
                let iconView = self.generateIconView(icon)
                hStackView.addArrangedSubview(iconView)
                
                NSLayoutConstraint.activate([
                    iconView.topAnchor.constraint(equalTo: hStackView.topAnchor),
                    iconView.bottomAnchor.constraint(equalTo: hStackView.bottomAnchor)
                ])
            }
            
            let remaining = 5 - SFSymbol.circleFillableSymbols.count % 5
            
            for _ in 0..<remaining {
                let row = (SFSymbol.circleFillableSymbols.count - 1) / 5
                
                let hStackView = vStackView.arrangedSubviews[row] as! NSStackView
                let view = NSView()
                hStackView.addArrangedSubview(view)
                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: hStackView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: hStackView.bottomAnchor)
                ])
            }
            
            Task { @MainActor in
                for await value in observationTrackingStream({ self.chosen }) {
                    for button in self.buttons {
                        guard let toolTip = button.toolTip else { continue }
                        let icon = SFSymbol(rawValue: toolTip)
                        
                        let flag = icon == value
                        button.flag = flag
                        button.showsBorderOnlyWhileMouseInside = !flag
                    }
                    
                    self.scrollToChosen(animated: true)
                }
            }
            
            indicatorView.removeFromSuperview()
            parentView.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: parentView.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
        }
    }
    
    func generateIconView(_ icon: SFSymbol) -> NSView {
        let button = NSButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonType(.onOff)
        button.toolTip = icon.rawValue
        button.image = icon.image.withSymbolConfiguration(.init(pointSize: 16, weight: .bold))
        button.bezelStyle = .flexiblePush
        button.showsBorderOnlyWhileMouseInside = true
        
        button.target = self
        button.action = #selector(self.chooseIcon(_:))
        
        buttons.append(button)
        
        return button
    }
    
    func scrollToChosen(animated: Bool = false) {
        guard let button = buttons.first(where: { button in
            guard let toolTip = button.toolTip else { return false }
            let icon = SFSymbol(rawValue: toolTip)
            
            return icon == chosen
        }) else { return }
        
        if let point = scrollPoint(for: button) {
            if animated {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    
                    scrollView?.contentView.setBoundsOrigin(point)
                }
            } else {
                scrollView?.contentView.scroll(to: point)
            }
        }
    }
    
    func scrollPoint(for button: NSButton) -> NSPoint? {
        guard
            let superview = button.superview,
            let view = scrollView?.contentView.documentView
        else { return nil }
        
        let height = scrollView?.frame.height ?? 0
        let scrollableHeight = view.frame.height - height
        let y = margin + superview.frame.midY - height / 2
        
        return .init(x: 0, y: max(0, min(y, scrollableHeight)))
    }
    
    func setAll(_ enabled: Bool) {
        buttons.forEach { $0.isEnabled = enabled }
    }
    
}

extension IconChooserViewController {
    
    @objc func chooseIcon(_ sender: Any?) {
        guard let button = sender as? NSButton else { return }
        guard let toolTip = button.toolTip else { return }
        
        let icon = SFSymbol(rawValue: toolTip)
        if chosen != icon {
            chosen = icon
        }
        
        button.flag = true
        
        chooseIconHandler?.chooseIcon(icon)
    }
    
}
