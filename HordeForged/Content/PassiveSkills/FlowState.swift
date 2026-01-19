import Foundation

let FlowState = AbilityDefinition(
    id: "flow_state",
    name: "Flow State",
    description: "Increases attack speed.",
    iconName: "flow_state",
    type: .passive,
    rarity: .common,
    maxLevel: 10,
    modifiers: [
        StatModifier(type: .attackSpeed, value: 0.10, isMultiplier: false)
    ]
)
