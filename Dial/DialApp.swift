//
//  DialApp.swift
//  Dial
//
//  Created by KrLite on 2024/3/20.
//

import SwiftUI
import Defaults
import SFSafeSymbols

@main
struct DialApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var isStatusItemPresented: Bool = false
    
    @State var statusItemIcon: SFSymbol = .circleFillableFallback
    
    @Default(.statusIconEnabled) var statusIconEnabled
    
    var body: some Scene {
    }
    
}
