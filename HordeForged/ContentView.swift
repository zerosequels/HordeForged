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
            GameViewRepresentable() // The SKView content will go here
                .ignoresSafeArea()

            VStack {
                PlayerInfoView()
                
                Spacer()
                
                ActionBarView()
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
