import Darwin

class Player: GameObject {
    init() {
        super.init(meshType: .Triangle)
    }
    
    override func update(deltaTime: Float) {
        let mouseViewportPos = Mouse.GetMouseViewportPosition()
        rotation.z = -atan2f(position.x - mouseViewportPos.x, position.y - mouseViewportPos.y)
        super.update(deltaTime: deltaTime)
    }
}
