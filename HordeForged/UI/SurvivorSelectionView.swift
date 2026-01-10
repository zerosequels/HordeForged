import SwiftUI
import SpriteKit

struct SurvivorSelectionView: View {
    @ObservedObject var appState: AppState
    
    // Grid Setup
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.abyssBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("CHOOSE YOUR SURVIVOR")
                    .font(.custom("Arial-BoldMT", size: 32))
                    .foregroundColor(.hordeGold)
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                    .padding(.top, 40)
                
                Spacer()
                
                // Central Preview
                VStack(spacing: 20) {
                    // Preview Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.shadowGray.opacity(0.5))
                            .frame(width: 200, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.hordeGold, lineWidth: 2)
                            )
                        
                        // Survivor Image (Static for now, could be animated later)
                        Image(appState.selectedSurvivor.assetPrefix + "_walk_down_0") // Assumes initial frame exists in assets
                            .resizable()
                            .interpolation(.none) // Pixel Art Style
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .scaleEffect(1.5)
                        
                        // Name Label
                        VStack {
                            Spacer()
                            Text(appState.selectedSurvivor.displayName)
                                .font(.custom("Arial-BoldMT", size: 24))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                        }
                    }
                    
                    // Info / Lock Status
                    if !SaveLoadManager.shared.isSurvivorUnlocked(appState.selectedSurvivor) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            Text("Locked")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    } else {
                        // Maybe show stats here later?
                        Text("Ready to Deploy")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .opacity(0.8)
                    }
                }
                
                Spacer()
                
                // Survivor List
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(SurvivorType.allCases) { survivor in
                            SurvivorCard(survivor: survivor, 
                                         isSelected: appState.selectedSurvivor == survivor, 
                                         isUnlocked: SaveLoadManager.shared.isSurvivorUnlocked(survivor))
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        appState.selectedSurvivor = survivor
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .frame(height: 120)
                .background(Color.black.opacity(0.3))
                
                // Start Button
                Button(action: {
                    if SaveLoadManager.shared.isSurvivorUnlocked(appState.selectedSurvivor) {
                        // Start Game
                        withAnimation {
                            appState.currentScreen = .game
                        }
                    }
                }) {
                    Text("BEGIN RUN")
                        .font(.custom("Arial-BoldMT", size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            SaveLoadManager.shared.isSurvivorUnlocked(appState.selectedSurvivor) ? Color.bloodRed : Color.gray
                        )
                        .cornerRadius(10)
                }
                .disabled(!SaveLoadManager.shared.isSurvivorUnlocked(appState.selectedSurvivor))
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .shadow(radius: 5)
            }
        }
    }
}

struct SurvivorCard: View {
    let survivor: SurvivorType
    let isSelected: Bool
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.hordeGold.opacity(0.3) : Color.shadowGray)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.hordeGold : Color.gray, lineWidth: isSelected ? 3 : 1)
                    )
                
                // Image
                Image(survivor.assetPrefix + "_walk_down_0")
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .saturation(isUnlocked ? 1.0 : 0.0) // Grayscale if locked
                    .opacity(isUnlocked ? 1.0 : 0.5)
                
                // Lock Overlay
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 20, height: 26)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            
            Text(survivor.displayName) // Short name?
                .font(.caption)
                .foregroundColor(isSelected ? .hordeGold : .gray)
                .lineLimit(1)
                .frame(width: 80)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
}
