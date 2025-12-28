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
    var background: some View {
        Color.abyssBlack
            .ignoresSafeArea()
    }

    var playerInfoView: some View {
        PlayerInfoView()
    }

    var actionBarView: some View {
        ActionBarView()
    }

    var body: some View {
        ZStack {
            self.background
            
            VStack {
                self.playerInfoView
                
                Spacer()
                
                self.actionBarView
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
