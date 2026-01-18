import SwiftUI

struct AbilityDetailView: View {
    let ability: AbilityInstance
    var onContinue: () -> Void
    
    // Calculate bonus based on first modifier for demo
    var bonusText: String {
        guard let mod = ability.definition.modifiers.first else { return "No Effect" }
        // Formula: Value * Level * 100
        let totalVal = mod.value * Double(ability.level) * 100
        let typeName = mod.type == .movementSpeed ? "Move Speed" : (mod.type == .damage ? "Damage" : "Stat")
        
        return "Total: +\(String(format: "%.0f", totalVal))% \(typeName)"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Icon
                Image(ability.definition.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(15)
                
                Text(ability.definition.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(ability.definition.description)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider().background(Color.white)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Level")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(ability.level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack {
                        Text("Current Bonus")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(bonusText)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer().frame(height: 40)
                
                Button(action: onContinue) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .background(Color.black.opacity(0.9)) // Inner background
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(20) // Outer padding
        }
    }
}
