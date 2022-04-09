import Darwin

class Pointer: GameObject {
    var camera: Camera
    
    init(camera: Camera) {
        self.camera = camera
        super.init(mesh: Triangle)
    }
    
    override func update(deltaTime: Float) {
        let mouseViewportPos = Mouse.GetMouseViewportPosition()
        rotation.z = -atan2f(
            position.x - mouseViewportPos.x - camera.position.x,
            position.y - mouseViewportPos.y - camera.position.y
        )
        super.update(deltaTime: deltaTime)
    }
}
