import SwiftUI

struct PlayerStats {
    let attackSpeed: Double
    let moveSpeed: Double
    let damage: Double
    
    var displayList: [(String, String)] {
        return [
            ("Attack Speed", formatPercent(attackSpeed)),
            ("Movement Speed", formatPercent(moveSpeed)),
            ("Damage Multiplier", formatPercent(damage))
        ]
    }
    
    private func formatPercent(_ val: Double) -> String {
        // val 1.5 = +50%
        // val 1.0 = +0%
        let p = (val - 1.0) * 100
        if p >= 0 {
            return "+\(String(format: "%.1f", p))%"
        } else {
            return "\(String(format: "%.1f", p))%"
        }
    }
}

struct StatsView: View {
    // Model Data passed in
    let activeAbilities: [AbilityInstance]
    let passiveAbilities: [AbilityInstance]
    let items: [ItemDefinition: Int]
    let stats: PlayerStats
    
    var onDismiss: () -> Void
    
    @State private var selectedItem: ItemDefinition? = nil
    @State private var selectedAbility: AbilityInstance? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Stats & Inventory")
                    .font(.title)
                    .foregroundColor(.hordeGold)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Active Abilities
                        sectionHeader(title: "Active Abilities")
                        ForEach(activeAbilities, id: \.definition.id) { ability in
                            Button(action: {
                                selectedAbility = ability
                            }) {
                                HStack {
                                    // Ability Icon
                                    Image(ability.definition.iconName)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                        .cornerRadius(8)
                                        .padding(.trailing, 8)
                                    
                                    Text(ability.definition.name)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("Level \(ability.level)")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }
                        }
                        
                        // Passive Abilities
                        sectionHeader(title: "Passive Abilities")
                        ForEach(passiveAbilities, id: \.definition.id) { ability in
                            Button(action: {
                                selectedAbility = ability
                            }) {
                                HStack {
                                    // Ability Icon
                                    Image(ability.definition.iconName)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                        .cornerRadius(8)
                                        .padding(.trailing, 8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(ability.definition.name)
                                        if let mod = ability.definition.modifiers.first {
                                            // Calculate bonus: Value * Level * 100
                                            let val = mod.value * Double(ability.level) * 100
                                            let typeName = mod.type == .movementSpeed ? "Move Speed" : (mod.type == .damage ? "Damage" : "Stat")
                                            Text("+\(String(format: "%.0f", val))% \(typeName)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Text("Level \(ability.level)")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }
                        }
                        
                        // Items
                        sectionHeader(title: "Items")
                        ForEach(Array(items.keys.sorted(by: { $0.name < $1.name })), id: \.id) { item in
                            Button(action: {
                                selectedItem = item
                            }) {
                                HStack {
                                    // Item Icon
                                    Image(item.iconName)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                        .cornerRadius(8)
                                        .padding(.trailing, 8)
                                        
                                    Text(item.name)
                                    Spacer()
                                    Text("x\(items[item]!)")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .contentShape(Rectangle()) // Make full row tappable
                            }
                        }
                        
                        // Player Stats
                        sectionHeader(title: "Current Bonuses")
                        ForEach(stats.displayList, id: \.0) { (name, value) in
                            HStack {
                                Text(name)
                                Spacer()
                                Text(value)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Button("Close") {
                    onDismiss()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom)
            }
            // Blur background when popup is active
            .blur(radius: (selectedItem != nil || selectedAbility != nil) ? 3 : 0)
            
            // Popup Overlay for Items
            if let item = selectedItem {
                ItemPickupView(item: item, count: items[item] ?? 0) {
                    selectedItem = nil
                }
                .transition(.opacity)
                .zIndex(1) // Ensure on top
            }
            
            // Popup Overlay for Abilities
            if let ability = selectedAbility {
                AbilityDetailView(ability: ability) {
                    selectedAbility = nil
                }
                .transition(.opacity)
                .zIndex(2) // Ensure on top
            }
        }
    }
    
    func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.top, 10)
    }
}
