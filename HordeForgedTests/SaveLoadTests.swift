import XCTest
@testable import HordeForged

final class SaveLoadTests: XCTestCase {
    
    var manager: SaveLoadManager!
    
    override func setUp() {
        super.setUp()
        manager = SaveLoadManager()
        manager.deleteSave() // Ensure clean slate
    }
    
    override func tearDown() {
        manager.deleteSave() // Clean up
        super.tearDown()
    }
    
    func testSavingAndLoading() {
        let save = DeepDwarfSave(runCount: 5, totalGold: 100, unlockedHeroes: ["dwarf_warrior"])
        
        do {
            try manager.save(save)
        } catch {
            XCTFail("Failed to save: \(error)")
        }
        
        let loadedSave = manager.load()
        XCTAssertNotNil(loadedSave)
        XCTAssertEqual(loadedSave?.runCount, 5)
        XCTAssertEqual(loadedSave?.totalGold, 100)
        XCTAssertEqual(loadedSave?.unlockedHeroes, ["dwarf_warrior"])
    }
    
    func testLoadReturnsNilWhenNoFile() {
        manager.deleteSave()
        let loadedSave = manager.load()
        XCTAssertNil(loadedSave)
    }
    
    func testPersistenceUpdate() {
        // Initial Save
        let initialSave = DeepDwarfSave(runCount: 1, totalGold: 10)
        try? manager.save(initialSave)
        
        // Modify and Overwrite
        var updatedSave = initialSave
        updatedSave.totalGold += 50
        try? manager.save(updatedSave)
        
        // Verify
        let loaded = manager.load()
        XCTAssertEqual(loaded?.totalGold, 60)
    }
}
