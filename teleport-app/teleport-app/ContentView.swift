//
//  ContentView.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var exportState = ExportState()
    
    var body: some View {
        HSplitView {
            MainView()
                .frame(minWidth: 600)
            
            VStack {
                ExportView(exportState: exportState)
                Spacer()
            }
            .frame(width: 300)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

#Preview {
    ContentView()
}
