import Foundation

struct Entity {
    let id: UUID
    private var components: [String: Component]

    init(id: UUID = UUID()) {
        self.id = id
        self.components = [:]
    }

    mutating func setComponent<T: Component>(_ component: T) {
        let typeName = String(describing: T.self)
        self.components[typeName] = component
    }

    mutating func removeComponent<T: Component>(ofType type: T.Type) {
        let typeName = String(describing: type)
        components[typeName] = nil
    }

    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        let typeName = String(describing: type)
        return components[typeName] as? T
    }
}
