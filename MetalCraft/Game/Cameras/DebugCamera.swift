
class DebugCamera: Camera {
    var type: CameraType = .DebugCamera
    var position: Float3 = Float3(0, 0, 0)
    
    func update(deltaTime: Float) {
        if (Keyboard.isKeyPressed(.LEFT)) {
            position.x -= deltaTime
        }
        if (Keyboard.isKeyPressed(.RIGHT)) {
            position.x += deltaTime
        }
        if (Keyboard.isKeyPressed(.UP)) {
            position.y += deltaTime
        }
        if (Keyboard.isKeyPressed(.DOWN)) {
            position.y -= deltaTime
        }
    }
    
    
}
