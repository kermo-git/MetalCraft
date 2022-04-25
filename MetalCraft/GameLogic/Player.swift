import simd

class Player {
    static var flySpeed: Float = 5
    static var mouseSpeed: Float = 0.005
    
    static var camera = Camera()
    
    static func update(deltaTime: Float) {
        let viewDir = camera.getViewDirection()
        let xzViewDir = normalize(Float2(viewDir.x, viewDir.z))
        
        let inc = deltaTime * flySpeed
        
        func moveOnXZ(direction: Float2) {
            camera.position.z += inc * direction.y
            camera.position.x -= inc * direction.x
        }
        
        if (Keyboard.isKeyPressed(.A)) {
            moveOnXZ(direction: turnCounterClockwise(xzViewDir))
        }
        if (Keyboard.isKeyPressed(.D)) {
            moveOnXZ(direction: turnClockwise(xzViewDir))
        }
        if (Keyboard.isKeyPressed(.W)) {
            moveOnXZ(direction: xzViewDir)
        }
        if (Keyboard.isKeyPressed(.S)) {
            moveOnXZ(direction: xzViewDir * -1)
        }
        
        if (Keyboard.isKeyPressed(.SHIFT)) {
            camera.position.y -= inc
        }
        if (Keyboard.isKeyPressed(.SPACE)) {
            camera.position.y += inc
        }
        camera.rotationY -= Mouse.getPositionDeltaX() * mouseSpeed
        camera.rotationX -= Mouse.getPositionDeltaY() * mouseSpeed
    }
}
