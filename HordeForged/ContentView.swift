//
//  ContentView.swift
//  HordeForged
//
//  Created by Nick Johnston on 12/27/25.
//

import SwiftUI

extension Color {
    static let hordeGold = Color(red: 0.8, green: 0.7, blue: 0.1)
    static let abyssBlack = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let bloodRed = Color(red: 0.7, green: 0.1, blue: 0.1)
    static let steelGray = Color(red: 0.6, green: 0.6, blue: 0.6)
    static let shadowGray = Color(red: 0.3, green: 0.3, blue: 0.3)
}

struct MainGameView: View {
    var body: some View {
        ZStack {
            // Use the new color
            Color.abyssBlack
                .ignoresSafeArea()
            
            VStack {
                // Player Info Placeholder
                Text("Player Name | HP: 100 | Gold: 0")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.steelGray.opacity(0.3))
                    .cornerRadius(8)
                
                Spacer()
                
                // Action Bar Placeholder
                HStack {
                    Button("Attack") {}
                        .padding()
                        .background(Color.bloodRed.opacity(0.6))
                        .cornerRadius(8)
                    Button("Skill") {}
                        .padding()
                        .background(Color.hordeGold.opacity(0.6))
                        .cornerRadius(8)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.steelGray.opacity(0.3))
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
