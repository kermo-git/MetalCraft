import simd

class FlyingCamera: Camera {
    let flySpeed: Float = 5
    let mouseSpeed: Float = 0.005
    
    init(startPos: Float3) {
        super.init()
        self.position = startPos
    }
    
    override func update(deltaTime: Float) {
        let viewDir = getViewDirection()
        let xzViewDir = normalize(Float2(viewDir.x, viewDir.z))
        
        let inc = deltaTime * flySpeed
        
        func moveOnXZ(direction: Float2) {
            position.z += inc * direction.y
            position.x -= inc * direction.x
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
            position.y -= inc
        }
        if (Keyboard.isKeyPressed(.SPACE)) {
            position.y += inc
        }
        rotationY -= Mouse.getPositionDeltaX() * mouseSpeed
        rotationX -= Mouse.getPositionDeltaY() * mouseSpeed
    }
}
