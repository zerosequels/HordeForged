import SwiftUI
import Combine

public enum AppScreen {
    case selection
    case game
}

public class AppState: ObservableObject {
    @Published public var currentScreen: AppScreen = .selection
    @Published public var selectedSurvivor: SurvivorType = .paladin
    @Published public var selectedSkin: SkinDefinition? = nil // Optional, defaults to def's first skin or none
    
    public init() {}
}
