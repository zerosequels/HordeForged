import SwiftUI
import Combine

public enum AppScreen {
    case selection
    case game
}

public class AppState: ObservableObject {
    @Published public var currentScreen: AppScreen = .selection
    @Published public var selectedSurvivor: SurvivorType = .paladin
    
    public init() {}
}
