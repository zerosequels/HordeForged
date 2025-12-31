import SwiftUI

struct UpgradeOption: Hashable {
    let definition: AbilityDefinition
    let currentLevel: Int // 0 if new
    let nextLevel: Int
}

struct LevelUpView: View {
    let options: [UpgradeOption]
    var onSelectUpgrade: (AbilityDefinition) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Level Up!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Choose an upgrade")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(options, id: \.self) { option in
                            UpgradeButton(
                                title: option.definition.name,
                                description: option.definition.description,
                                levelText: option.currentLevel == 0 ? "New!" : "Lv \(option.currentLevel) -> \(option.nextLevel)"
                            ) {
                                onSelectUpgrade(option.definition)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct UpgradeButton: View {
    let title: String
    let description: String
    let levelText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(levelText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
        }
        .frame(height: 60)
    }
}
