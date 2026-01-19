import Foundation

let ArcaneKnowledge = AbilityDefinition(
    id: "arcane_knowledge",
    name: "Arcane Knowledge",
    description: "Increases barrier gained per experience.",
    iconName: "arcane_knowledge",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .barrierPerExp, value: 1.0, isMultiplier: false)
    ]
)
