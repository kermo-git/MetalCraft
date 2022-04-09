
class DebugCamera: Camera {
    var type: CameraType = .DebugCamera
    var projectionMatrix: Float4x4 {
        perspective(degreesFov: 45,
                    aspectRatio: Renderer.aspectRatio,
                    near: 0.1,
                    far: 1000)
    }
    var position: Float3 = Float3(0, 0, 0)
    var rotation: Float3 = Float3(0, 0, 0)
    var speed: Float
    
    init(speed: Float = 1) {
        self.speed = speed
    }
    
    func update(deltaTime: Float) {
        let inc = deltaTime * speed
        if (Keyboard.isKeyPressed(.A)) {
            position.x -= inc
        }
        if (Keyboard.isKeyPressed(.D)) {
            position.x += inc
        }
        if (Keyboard.isKeyPressed(.SHIFT)) {
            position.y -= inc
        }
        if (Keyboard.isKeyPressed(.SPACE)) {
            position.y += inc
        }
        if (Keyboard.isKeyPressed(.W)) {
            position.z -= inc
        }
        if (Keyboard.isKeyPressed(.S)) {
            position.z += inc
        }
        if (Keyboard.isKeyPressed(.DOWN)) {
            rotation.x -= inc
        }
        if (Keyboard.isKeyPressed(.UP)) {
            rotation.x += inc
        }
        if (Keyboard.isKeyPressed(.RIGHT)) {
            rotation.y -= inc
        }
        if (Keyboard.isKeyPressed(.LEFT)) {
            rotation.y += inc
        }
    }
}
