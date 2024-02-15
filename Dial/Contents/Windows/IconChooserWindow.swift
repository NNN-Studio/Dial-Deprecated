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
        let view = NSView()
        let columns: Int = 5
        let vStackView = NSStackView()
        view.addSubview(vStackView)
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.orientation = .vertical
        vStackView.distribution = .fillEqually
        
        for (index, icon) in SFSymbol.circleFillableSymbols.enumerated() {
            let row = index / columns
            
            if vStackView.arrangedSubviews.count <= row {
                let hStackView = NSStackView()
                vStackView.addArrangedSubview(hStackView)
                
                hStackView.translatesAutoresizingMaskIntoConstraints = false
                hStackView.orientation = .horizontal
                hStackView.distribution = .fillEqually
                
                NSLayoutConstraint.activate([
                    hStackView.heightAnchor.constraint(equalToConstant: 35),
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
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 275),
            vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        IconChooserViewController.view = view
        print("View preloaded for icon chooser:", view)
    }
    
    static var view: NSView = .init()
    
    static func generateIconView(_ icon: SFSymbol) -> NSView {
        let view = NSView()
        let imageView = NSImageView(image: icon.image.withSymbolConfiguration(.init(pointSize: 20, weight: .bold))!)
        view.addSubview(imageView)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = IconChooserViewController.view // Preloaded
    }
    
}
