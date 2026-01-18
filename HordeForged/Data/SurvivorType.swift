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
    // case iron_golem // Removed (Skin)
    case pyromancer
    case red_wizard
    case samurai
    case sorcerer
    case spellblade
    // case stone_golem // Removed (Skin)
    case terramancer
    
    public var id: String { rawValue }
    
    public var definition: SurvivorDefinition {
        switch self {
        case .paladin: return PaladinSurvivor
        case .aeromancer: return AeromancerSurvivor
        case .blackswordsman: return BlackSwordsmanSurvivor
        case .cleric: return ClericSurvivor
        case .dracula: return DraculaSurvivor
        case .druid: return DruidSurvivor
        case .golem: return GolemSurvivor
        case .herald: return HeraldSurvivor
        case .hermit: return HermitSurvivor
        case .hydromancer: return HydromancerSurvivor
        case .pyromancer: return PyromancerSurvivor
        case .red_wizard: return RedWizardSurvivor
        case .samurai: return SamuraiSurvivor
        case .sorcerer: return SorcererSurvivor
        case .spellblade: return SpellbladeSurvivor
        case .terramancer: return TerramancerSurvivor
        }
    }
    
    public var displayName: String {
        return definition.name
    }
    
    public var assetPrefix: String {
        // Default to definition's character name
        return definition.characterName
    }
    
    public var isUnlockedByDefault: Bool {
        // Use logic or definition defaults?
        // Staying strict to prior logic for now but using definition data would be better long term
        switch self {
        case .paladin, .red_wizard, .cleric:
            return true
        default:
            return false // Golem, etc unlockable
        }
    }
    
    /// The specific order survivors should be displayed in the UI.
    public static let ordered: [SurvivorType] = [
        // Heroes (Defaults)
        .paladin, .cleric, .red_wizard,
        
        // Fighters
        .samurai, .blackswordsman, .spellblade,
        
        // Elementalists
        .pyromancer, .hydromancer, .aeromancer, .terramancer,
        
        // Mystics
        .druid, .sorcerer, .hermit, .herald, .dracula,
        
        // Constructs
        .golem
    ]
}
