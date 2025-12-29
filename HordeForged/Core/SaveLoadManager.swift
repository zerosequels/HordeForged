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
    
    public func save(_ data: DeepDwarfSave) throws {
        guard let fileURL = saveFileURL else {
            throw SaveLoadError.missingDirectory
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)
    }
    
    public func load() -> DeepDwarfSave? {
        guard let fileURL = saveFileURL else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(DeepDwarfSave.self, from: data)
        } catch {
            print("Failed to load save: \(error)")
            return nil
        }
    }
    
    public func deleteSave() {
        guard let fileURL = saveFileURL else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}

public enum SaveLoadError: Error {
    case missingDirectory
}
