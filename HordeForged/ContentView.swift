//
//  ContentView.swift
//  HordeForged
//
//  Created by Nick Johnston on 12/27/25.
//

import SwiftUI

struct MainGameView: View {
    var body: some View {
        ZStack {
            // Placeholder background
            Color.black.opacity(0.9) // Dark aesthetic
                .ignoresSafeArea()
            
            VStack {
                // Player Info Placeholder
                Text("Player Name | HP: 100 | Gold: 0")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                
                Spacer()
                
                // Action Bar Placeholder
                HStack {
                    Button("Attack") {}
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(8)
                    Button("Skill") {}
                        .padding()
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(8)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.3))
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        MainGameView()
    }
}

#Preview {
    ContentView()
}