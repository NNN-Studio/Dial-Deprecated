//
//  IconChooserWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/15.
//

import Foundation
import AppKit
import SFSafeSymbols

@Observable class IconChooserViewController: NSViewController {
    
    private var buttons: [NSButton] = []
    
    var chosen: SFSymbol = .circleFillableFallback
    
    var scrollView: NSScrollView? {
        get {
            view as? NSScrollView
        }
        
        set {
            guard let newValue else { return }
            
            view = newValue
        }
    }
    
    func preloadView() {
        buttons = []
        
        let scrollView = NSScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalToConstant: 275),
            scrollView.heightAnchor.constraint(equalToConstant: 375)
        ])
        
        let wrapperView = NSView()
        scrollView.documentView = wrapperView
        
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor)
        ])
        
        let vStackView = NSStackView()
        let columns: Int = 5
        wrapperView.addSubview(vStackView)
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.orientation = .vertical
        
        NSLayoutConstraint.activate([
            vStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 12),
            vStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -12),
            vStackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 12),
            vStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -12)
        ])
        
        for (index, icon) in SFSymbol.circleFillableSymbols
            .sorted(by: { $0.rawValue < $1.rawValue })
            .enumerated() {
            let row = index / columns
            
            if vStackView.arrangedSubviews.count <= row {
                let hStackView = NSStackView()
                vStackView.addArrangedSubview(hStackView)
                
                hStackView.translatesAutoresizingMaskIntoConstraints = false
                hStackView.orientation = .horizontal
                hStackView.distribution = .fillEqually
                
                NSLayoutConstraint.activate([
                    hStackView.heightAnchor.constraint(equalToConstant: 50),
                    hStackView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
                    hStackView.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
                ])
            }
            
            let hStackView = vStackView.arrangedSubviews[row] as! NSStackView
            let iconView = generateIconView(icon)
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
                print(value.rawValue)
                for button in buttons {
                    guard let toolTip = button.toolTip else { continue }
                    let icon = SFSymbol(rawValue: toolTip)
                    
                    if icon != value {
                        button.flag = false
                    }
                }
            }
        }
        
        self.scrollView = scrollView
        print("View preloaded for icon chooser:", view)
    }
    
    func generateIconView(_ icon: SFSymbol) -> NSView {
        let button = NSButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = icon.rawValue
        button.image = icon.image.withSymbolConfiguration(.init(pointSize: 16, weight: .bold))
        button.bezelStyle = .flexiblePush
        button.setButtonType(.onOff)
        
        button.target = self
        button.action = #selector(self.chooseIcon(_:))
        
        buttons.append(button)
        
        return button
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
    }
    
}
