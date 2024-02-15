//
//  IconChooserWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/15.
//

import Foundation
import AppKit
import SFSafeSymbols

class IconChooserViewController: NSViewController {
    
    static func preloadView() {
        let scrollView = NSScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalToConstant: 275),
            scrollView.heightAnchor.constraint(equalToConstant: 375)
        ])
        
        let vStackView = NSStackView()
        let columns: Int = 5
        scrollView.documentView = vStackView
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.orientation = .vertical
        
        NSLayoutConstraint.activate([
            vStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            vStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12)
        ])
        
        for (index, icon) in SFSymbol.circleFillableSymbols.enumerated() {
            let row = index / columns
            
            if vStackView.arrangedSubviews.count <= row {
                let hStackView = NSStackView()
                vStackView.addArrangedSubview(hStackView)
                
                hStackView.translatesAutoresizingMaskIntoConstraints = false
                hStackView.orientation = .horizontal
                hStackView.distribution = .fillEqually
                
                NSLayoutConstraint.activate([
                    hStackView.heightAnchor.constraint(equalToConstant: 55),
                    hStackView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
                    hStackView.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
                ])
            }
            
            let hStackView = vStackView.arrangedSubviews[row] as! NSStackView
            let iconView = IconChooserViewController.generateIconView(icon)
            hStackView.addArrangedSubview(iconView)
            
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: hStackView.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: hStackView.bottomAnchor)
            ])
        }
        
        let remaining = 5 - SFSymbol.circleFillableSymbols.count % 5
        
        for index in 0..<remaining {
            let row = (SFSymbol.circleFillableSymbols.count - 1) / 5
            
            let hStackView = vStackView.arrangedSubviews[row] as! NSStackView
            let view = NSView()
            hStackView.addArrangedSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: hStackView.topAnchor),
                view.bottomAnchor.constraint(equalTo: hStackView.bottomAnchor)
            ])
        }
        
        IconChooserViewController.view = scrollView
        print("View preloaded for icon chooser:", view)
    }
    
    static var view: NSView = .init()
    
    static func generateIconView(_ icon: SFSymbol) -> NSView {
        let box = NSBox()
        let imageView = NSImageView(image: icon.image.withSymbolConfiguration(.init(pointSize: 16, weight: .bold))!)
        box.addSubview(imageView)
        
        box.translatesAutoresizingMaskIntoConstraints = false
        box.titlePosition = .noTitle
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return box
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view = IconChooserViewController.view // Preloaded
    }
    
}
