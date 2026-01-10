import Foundation

public enum SurvivorType: String, CaseIterable, Identifiable, Codable {
    case paladin
    case aeromancer
    case blackswordsman
    case cleric
    case dracula
    case druid
    case golem
    case herald
    case hermit
    case hydromancer
    case iron_golem
    case pyromancer
    case red_wizard
    case samurai
    case sorcerer
    case spellblade
    case stone_golem
    case terramancer
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .blackswordsman: return "Black Swordsman"
        case .red_wizard: return "Red Wizard"
        case .iron_golem: return "Iron Golem"
        case .stone_golem: return "Stone Golem"
        default:
            return rawValue.capitalized
        }
    }
    
    public var assetPrefix: String {
        return "survivor_\(rawValue)"
    }
    
    public var isUnlockedByDefault: Bool {
        switch self {
        case .paladin, .red_wizard, .cleric:
            return true
        default:
            return false
        }
    }
}
