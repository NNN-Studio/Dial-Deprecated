//
//  SettingsView.swift
//  Dial
//
//  Created by KrLite on 2024/3/20.
//

import SwiftUI

struct SettingsView: View {
    @State var tab = 0
    
    var body: some View {
        TabView(selection: $tab) {
            GeneralSettingsView()
                .tag(0)
                .tabItem {
                    Image(systemSymbol: .gear)
                    Text("General")
                }
            
            DialMenuSettingsView()
                .tag(1)
                .tabItem {
                    Image(systemSymbol: .circleCircle)
                    Text("Dial Menu")
                }
            
            ControllersSettingsView()
                .tag(2)
                .tabItem {
                    Image(systemSymbol: .hockeyPuck)
                    Text("Controllers")
                }
            
            MoreSettingsView()
                .tag(1)
                .tabItem {
                    Image(systemSymbol: .ellipsisCircle)
                    Text("More")
                }
        }
    }
}

#Preview {
    SettingsView()
}
