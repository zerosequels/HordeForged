import SwiftUI

struct ItemPickupView: View {
    let item: ItemDefinition
    let count: Int
    var onContinue: () -> Void
    
    // Calculate bonus based on first modifier for demo
    var bonusText: String {
        guard let mod = item.modifiers.first else { return "No Effect" }
        let totalVal = mod.value * Double(count) * 100 // assuming percentage
        let typeName = "\(mod.type)".capitalized
        // Rough formatting
        return "Total: +\(String(format: "%.1f", totalVal))% \(typeName)"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Icon (Placeholder)
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.hordeGold)
                    .frame(width: 80, height: 80)
                    .overlay(Text("?").font(.largeTitle).foregroundColor(.black))
                
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(item.description)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Divider().background(Color.white)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Stacks")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(count)")
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
                    Text("Continue")
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
        }
    }
}
