import Foundation

struct Entity {
    let id: UUID
    private var components: [ObjectIdentifier: Component]

    init(id: UUID = UUID()) {
        self.id = id
        self.components = [:]
    }

    // Set or update a component. If component is nil, remove it.
    mutating func setComponent<T: Component>(_ component: T?) {
        let typeId = ObjectIdentifier(T.self)
        if let component = component {
            self.components[typeId] = component
        } else {
            self.components[typeId] = nil
        }
    }

    // Retrieve a component of a specific type
    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        return components[ObjectIdentifier(type)] as? T
    }
}
