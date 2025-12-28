import Foundation

struct Entity {
    let id: UUID
    private var components: [ObjectIdentifier: Component]

    init(id: UUID = UUID()) {
        self.id = id
        self.components = [:]
    }

    mutating func addComponent(_ component: Component) {
        self.components[ObjectIdentifier(type(of: component))] = component
    }

    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        return components[ObjectIdentifier(type)] as? T
    }

    mutating func removeComponent<T: Component>(ofType type: T.Type) {
        self.components[ObjectIdentifier(type)] = nil
    }
}
