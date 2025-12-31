import SwiftUI

struct GameOverView: View {
    let isVictory: Bool
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(isVictory ? "VICTORY!" : "DEFEAT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(isVictory ? .yellow : .red)
                
                Text(isVictory ? "You survived the horde." : "You have fallen.")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Button(action: onRestart) {
                    Text("Restart Game")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
        }
    }
}
