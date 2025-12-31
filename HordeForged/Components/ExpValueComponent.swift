import GameplayKit

class ExpValueComponent: GKComponent {
    var value: Int
    
    init(value: Int) {
        self.value = value
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
