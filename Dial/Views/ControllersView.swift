//
//  ControllersView.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import SwiftUI

struct ControllersView: View {
    
    @State private var pick = 0
    
    var body: some View {
        ZStack {
            Color.green
            
            VStack {
                Text("List 1")
                
                Text("List 2")
                
                Text("List 3")
            }
        }
    }
    
}

#Preview {
    
    ControllersView()
    
}
