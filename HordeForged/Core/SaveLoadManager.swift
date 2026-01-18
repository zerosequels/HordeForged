import Foundation

public class SaveLoadManager {
    public static let shared = SaveLoadManager()
    
    private let fileName = "save.json"
    
    private var saveFileURL: URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    public init() {}
    
    private var cachedSave: DeepDwarfSave?
    
    public func save(_ data: DeepDwarfSave) throws {
        guard let fileURL = saveFileURL else {
            throw SaveLoadError.missingDirectory
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)
        
        // Update Cache
        self.cachedSave = data
    }
    
    public func load() -> DeepDwarfSave? {
        // Return memory cache if available
        if let cache = cachedSave {
            return cache
        }
        
        guard let fileURL = saveFileURL else { return nil }
        
        // Check existence first to avoid error log spam on new installs
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            var save = try decoder.decode(DeepDwarfSave.self, from: data)
            
            // Ensure default heroes are unlocked (migrating old saves or fixing data)
            let defaults = SurvivorType.allCases.filter { $0.isUnlockedByDefault }.map { $0.rawValue }
            let existing = Set(save.unlockedHeroes)
            let missing = defaults.filter { !existing.contains($0) }
            
            if !missing.isEmpty {
                save.unlockedHeroes.append(contentsOf: missing)
                try? self.save(save) // Auto-save the fix
            }
            
            // Update Cache
            self.cachedSave = save
            
            return save
        } catch {
            print("Failed to load save: \(error)")
            return nil
        }
    }
    
    // MARK: - Survivor Unlocks
    
    public func getUnlockedSurvivors() -> [SurvivorType] {
        guard let save = load() else {
            // No save? Return defaults
            return SurvivorType.allCases.filter { $0.isUnlockedByDefault }
        }
        
        // compactMap in case save file has strings that no longer match enum
        return save.unlockedHeroes.compactMap { SurvivorType(rawValue: $0) }
    }
    
    public func isSurvivorUnlocked(_ type: SurvivorType) -> Bool {
        #if DEBUG
        return true
        #endif
        
        if type.isUnlockedByDefault { return true }
        
        guard let save = load() else { return false }
        return save.unlockedHeroes.contains(type.rawValue)
    }
    
    public func unlockSurvivor(_ type: SurvivorType) {
        if isSurvivorUnlocked(type) { return }
        
        var currentSave = load() ?? DeepDwarfSave()
        currentSave.unlockedHeroes.append(type.rawValue)
        
        do {
            try save(currentSave)
            print("Unlocked survivor: \(type.displayName)")
        } catch {
            print("Failed to save unlock: \(error)")
        }
    }
    
    public func deleteSave() {
        guard let fileURL = saveFileURL else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Clear Cache
        self.cachedSave = nil
    }
}

public enum SaveLoadError: Error {
    case missingDirectory
}
