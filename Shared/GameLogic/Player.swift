import simd

class Player {
    static let flySpeed: Float = 5
    static let mouseSpeed: Float = 0.005
    
    static var rotationX: Float = 0
    static var rotationY: Float = 0
    static var position: Float3 = Float3(0, 20, 0)
    
    static func getViewDirection() -> Float3 {
        let rotation = rotateAroundY(rotationY) * rotateAroundX(rotationX)
        let result4 = Float4(0, 0, -1, 1) * rotation
        return Float3(result4.x, result4.y, result4.z)
    }
    
    static func getViewMatrix() -> Float4x4 {
        return rotateAroundX(-rotationX) *
               rotateAroundY(-rotationY) *
               translate(-position.x, -position.y, -position.z)
    }
    
    static func update(deltaTime: Float) {
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
