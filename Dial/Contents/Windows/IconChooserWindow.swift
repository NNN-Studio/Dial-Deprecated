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
        let vStackView = NSStackView()
        let columns: Int = 5
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.orientation = .vertical
        
        for (index, icon) in SFSymbol.circleFillableSymbols.enumerated() {
            let row = index / columns
            
            if vStackView.arrangedSubviews.count <= row {
                let hStackView = NSStackView()
                vStackView.addArrangedSubview(hStackView)
                
                hStackView.translatesAutoresizingMaskIntoConstraints = false
                hStackView.orientation = .horizontal
                
                NSLayoutConstraint.activate([
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
        
        IconChooserViewController.view = vStackView
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
        
        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: 50),
            box.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        return box
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = IconChooserViewController.view // Preloaded
    }
    
}
