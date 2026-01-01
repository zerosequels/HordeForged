import Foundation

let ElixirOfAlacrity = ItemDefinition(
    id: "elixir_of_alacrity",
    name: "Elixir of Alacrity",
    description: "+15% Attack Speed",
    rarity: .common,
    modifiers: [
        StatModifier(type: .attackSpeed, value: 0.15, isMultiplier: false)
    ]
)
