import Foundation

struct SurvivorDefinition {
    let id: String
    let name: String
    let description: String
    let characterName: String // Used for Sprite/Animation assets
    let startingActiveSkill: AbilityDefinition
    let startingPassiveSkill: AbilityDefinition
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

let AllSurvivors: [SurvivorDefinition] = [PaladinSurvivor, RedWizardSurvivor, ClericSurvivor]
