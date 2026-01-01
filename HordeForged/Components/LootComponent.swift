import GameplayKit

enum LootType {
    case expOrb
    case healthPotion
    case item(String) // ID of the ItemDefinition
    case randomItem
}

struct LootItem {
    let type: LootType
    let value: Int // Amount (XP amount, heal amount, or stack count)
    let chance: Double // 0.0 to 1.0
}

class LootComponent: GKComponent {
    var lootTable: [LootItem]
    
    init(lootTable: [LootItem]) {
        self.lootTable = lootTable
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
