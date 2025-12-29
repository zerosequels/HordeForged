import Foundation

public struct DeepDwarfSave: Codable, Equatable {
    public var runCount: Int
    public var totalGold: Int
    public var unlockedHeroes: [String]
    public var lastPlayedDate: Date
    
    public init(runCount: Int = 0, totalGold: Int = 0, unlockedHeroes: [String] = [], lastPlayedDate: Date = Date()) {
        self.runCount = runCount
        self.totalGold = totalGold
        self.unlockedHeroes = unlockedHeroes
        self.lastPlayedDate = lastPlayedDate
    }
}
