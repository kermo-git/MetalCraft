
class FlyingCamera: Camera {
    var projectionMatrix: Float4x4 {
        perspective(degreesFov: 45,
                    aspectRatio: Renderer.aspectRatio,
                    near: 0.1,
                    far: 1000)
    }
    var rotationX: Float = 0
    var rotationY: Float = 0
    var position: Float3 = Float3(0, 0, 0)
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
            rotationX -= inc
        }
        if (Keyboard.isKeyPressed(.UP)) {
            rotationX += inc
        }
        if (Keyboard.isKeyPressed(.RIGHT)) {
            rotationY -= inc
        }
        if (Keyboard.isKeyPressed(.LEFT)) {
            rotationY += inc
        }
    }
}
