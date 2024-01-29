import simd

class Camera {
    var rotationX: Float = 0
    var rotationY: Float = 0
    var position: Float3
    var degreesFov: Float = 45
    
    var moveForward = false
    var moveBackward = false
    var moveLeft = false
    var moveRight = false
    var moveUp = false
    var moveDown = false
    
    let moveSpeed: Float = 5
    let rotateSpeed: Float = 0.005
    
    private var rotationInputDeltaX: Float = 0
    private var rotationInputDeltaY: Float = 0
    
    init(startPos: Float3 = Float3(0, 0, 0)) {
        self.position = startPos
    }
    
    func setRotationInput(_ deltaX: Float, _ deltaY: Float) {
        self.rotationInputDeltaX = deltaX
        self.rotationInputDeltaY = deltaY
    }
    
    private func getRotationInputDeltaX() -> Float {
        let result = rotationInputDeltaX
        rotationInputDeltaX = 0
        return result
    }
    
    private func getRotationInputDeltaY() -> Float {
        let result = rotationInputDeltaY
        rotationInputDeltaY = 0
        return result
    }
    
    var viewDirection: Float3 {
        let rotation = rotateAroundY(rotationY) * rotateAroundX(rotationX)
        let result4 = Float4(0, 0, -1, 1) * rotation
        return Float3(result4.x, result4.y, result4.z)
    }
    
    var viewMatrix: Float4x4 {
        return rotateAroundX(-rotationX) *
               rotateAroundY(-rotationY) *
               translate(-position.x, -position.y, -position.z)
    }
    
    func update(deltaTime: Float) {
        let viewDir = viewDirection
        let xzViewDir = normalize(Float2(viewDir.x, viewDir.z))
        
        let moveDistance = deltaTime * moveSpeed
        
        func moveOnXZ(direction: Float2) {
            position.z += moveDistance * direction.y
            position.x -= moveDistance * direction.x
        }
        
        if (moveLeft) {
            moveOnXZ(direction: turnCounterClockwise(xzViewDir))
        }
        if (moveRight) {
            moveOnXZ(direction: turnClockwise(xzViewDir))
        }
        if (moveForward) {
            moveOnXZ(direction: xzViewDir)
        }
        if (moveBackward) {
            moveOnXZ(direction: xzViewDir * -1)
        }
        
        if (moveDown) {
            position.y -= moveDistance
        }
        if (moveUp) {
            position.y += moveDistance
        }
        rotationY -= getRotationInputDeltaX() * rotateSpeed
        
        let newRotationX = rotationX - getRotationInputDeltaY() * rotateSpeed
        if (abs(newRotationX) < RIGHT_ANGLE_RADIANS) {
            rotationX = newRotationX
        }
    }
    
    private let RIGHT_ANGLE_RADIANS = toRadians(90)
}
