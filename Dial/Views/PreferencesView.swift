//
//  PreferencesView.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import SwiftUI

struct PreferencesView: View {
    
    @State private var tab = 0
    
    var body: some View {
        TabView(selection: $tab) {
            ControllersView()
                .tabItem { Text("Controllers") }
            
            DialView()
                .tabItem { Text("Dial") }
        }
        .frame(
            minWidth: 300, maxWidth: 300,
            minHeight: 450
        )
    }
    
}

#Preview {
    
    PreferencesView()
    
}
