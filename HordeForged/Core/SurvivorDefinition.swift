import Foundation

public enum UnlockCondition {
    case `default`
    case achievement(id: String)
    case premium // e.g. IAP
}

public struct SkinDefinition {
    public let id: String
    public let name: String // Display Name
    public let characterName: String // Asset Base Name
    public let description: String
    public let unlockCondition: UnlockCondition
    
    public init(id: String, name: String, characterName: String, description: String, unlockCondition: UnlockCondition) {
        self.id = id
        self.name = name
        self.characterName = characterName
        self.description = description
        self.unlockCondition = unlockCondition
    }
}

public struct SurvivorDefinition {
    public let id: String
    public let name: String
    public let description: String
    public let characterName: String // Default Asset Base Name
    public let startingActiveSkill: AbilityDefinition
    public let startingPassiveSkill: AbilityDefinition
    public let skins: [SkinDefinition]
    
    public init(id: String, name: String, description: String, characterName: String, startingActiveSkill: AbilityDefinition, startingPassiveSkill: AbilityDefinition, skins: [SkinDefinition] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.characterName = characterName
        self.startingActiveSkill = startingActiveSkill
        self.startingPassiveSkill = startingPassiveSkill
        self.skins = skins
    }
}

// Global Definitions
let PaladinSurvivor = SurvivorDefinition(
    id: "paladin",
    name: "Paladin",
    description: "A holy warrior with thunderous power.",
    characterName: "survivor_paladin",
    startingActiveSkill: Thunderclap,
    startingPassiveSkill: GiantsStrength
)

let RedWizardSurvivor = SurvivorDefinition(
    id: "red_wizard",
    name: "Red Wizard",
    description: "A master of arcane and fire magic.",
    characterName: "survivor_red_wizard",
    startingActiveSkill: ArcaneBolt,
    startingPassiveSkill: ManaShield
)

let ClericSurvivor = SurvivorDefinition(
    id: "cleric",
    name: "Cleric",
    description: "A divine healer and smiter.",
    characterName: "survivor_cleric",
    startingActiveSkill: Smite,
    startingPassiveSkill: Celerity
)

// -- New Survivors --

let AeromancerSurvivor = SurvivorDefinition(
    id: "aeromancer",
    name: "Aeromancer",
    description: "Control the winds to slash through foes.",
    characterName: "survivor_aeromancer",
    startingActiveSkill: WindSlash,
    startingPassiveSkill: Tailwind
)

let BlackSwordsmanSurvivor = SurvivorDefinition(
    id: "black_swordsman",
    name: "Black Swordsman",
    description: "A cursed warrior dealing heavy damage.",
    characterName: "survivor_blackswordsman",
    startingActiveSkill: DarkSever,
    startingPassiveSkill: Cruelty
)

let DraculaSurvivor = SurvivorDefinition(
    id: "dracula",
    name: "Dracula",
    description: "Drain the life of your enemies.",
    characterName: "survivor_dracula",
    startingActiveSkill: SanguineBolt,
    startingPassiveSkill: Vampirism
)

let DruidSurvivor = SurvivorDefinition(
    id: "druid",
    name: "Druid",
    description: "A guardian of nature.",
    characterName: "survivor_druid",
    startingActiveSkill: VineLash,
    startingPassiveSkill: NaturesGift
)

let HeraldSurvivor = SurvivorDefinition(
    id: "herald",
    name: "Herald",
    description: "A messenger of divine light.",
    characterName: "survivor_herald",
    startingActiveSkill: DivineDecree,
    startingPassiveSkill: Conviction
)

let HermitSurvivor = SurvivorDefinition(
    id: "hermit",
    name: "Hermit",
    description: "A resourceful wanderer.",
    characterName: "survivor_hermit",
    startingActiveSkill: StoneThrow,
    startingPassiveSkill: Foraging
)

let HydromancerSurvivor = SurvivorDefinition(
    id: "hydromancer",
    name: "Hydromancer",
    description: "Master of the tides.",
    characterName: "survivor_hydromancer",
    startingActiveSkill: TidalWave,
    startingPassiveSkill: FlowState
)

let PyromancerSurvivor = SurvivorDefinition(
    id: "pyromancer",
    name: "Pyromancer",
    description: "Incinerate everything.",
    characterName: "survivor_pyromancer",
    startingActiveSkill: Fireball,
    startingPassiveSkill: Combustion
)

let SamuraiSurvivor = SurvivorDefinition(
    id: "samurai",
    name: "Samurai",
    description: "A disciplined warrior with lethal precision.",
    characterName: "survivor_samurai",
    startingActiveSkill: Iaido,
    startingPassiveSkill: Focus
)

let SorcererSurvivor = SurvivorDefinition(
    id: "sorcerer",
    name: "Sorcerer",
    description: "Arcane scholar dealing constant damage.",
    characterName: "survivor_sorcerer",
    startingActiveSkill: MagicMissile,
    startingPassiveSkill: ArcaneKnowledge
)

let SpellbladeSurvivor = SurvivorDefinition(
    id: "spellblade",
    name: "Spellblade",
    description: "Weaves magic into melee combat.",
    characterName: "survivor_spellblade",
    startingActiveSkill: ArcaneStrike,
    startingPassiveSkill: EnchantedArmor
)

let TerramancerSurvivor = SurvivorDefinition(
    id: "terramancer",
    name: "Terramancer",
    description: "Shaping the earth to crush foes.",
    characterName: "survivor_terramancer",
    startingActiveSkill: Boulder,
    startingPassiveSkill: Stability
)

// -- Golem (Construct) --
let GolemSurvivor = SurvivorDefinition(
    id: "golem",
    name: "The Construct",
    description: "An animated guardian.",
    characterName: "survivor_golem", // Clay/Standard
    startingActiveSkill: Tremor,
    startingPassiveSkill: ObsidianSkin,
    skins: [
        SkinDefinition(id: "golem_clay", name: "Clay Golem", characterName: "survivor_golem", description: "Standard Clay Construct", unlockCondition: .default),
        SkinDefinition(id: "golem_stone", name: "Stone Golem", characterName: "survivor_stone_golem", description: "Hardened Stone", unlockCondition: .achievement(id: "unlock_stone_golem")),
        SkinDefinition(id: "golem_iron", name: "Iron Golem", characterName: "survivor_iron_golem", description: "Forged Iron", unlockCondition: .achievement(id: "unlock_iron_golem"))
    ]
)

let AllSurvivors: [SurvivorDefinition] = [
    PaladinSurvivor, 
    RedWizardSurvivor, 
    ClericSurvivor,
    AeromancerSurvivor,
    BlackSwordsmanSurvivor,
    DraculaSurvivor,
    DruidSurvivor,
    GolemSurvivor,
    HeraldSurvivor,
    HermitSurvivor,
    HydromancerSurvivor,
    PyromancerSurvivor,
    SamuraiSurvivor,
    SorcererSurvivor,
    SpellbladeSurvivor,
    TerramancerSurvivor
]
