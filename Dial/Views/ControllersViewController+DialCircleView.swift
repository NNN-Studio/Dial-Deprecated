//
//  DialCircleViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/17.
//

import Foundation
import AppKit

extension ControllersViewController {
    
    func loadDialCircleViewInto(_ superview: NSView) {
        let backgroundView = NSVisualEffectView()
        superview.addSubview(backgroundView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.blendingMode = .behindWindow
        backgroundView.material = .underPageBackground
        
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = superview.frame.size.height / 2
        backgroundView.state = .active
        
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalTo: superview.widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: superview.heightAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
}
