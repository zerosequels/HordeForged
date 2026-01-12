import Foundation

let ElixirOfAlacrity = ItemDefinition(
    id: "elixir_of_alacrity",
    name: "Elixir of Alacrity",
    description: "+15% Attack Speed",
    rarity: .common,
    iconName: "elixir_of_alacrity",
    modifiers: [
        StatModifier(type: .attackSpeed, value: 0.15, isMultiplier: false)
    ]
)
