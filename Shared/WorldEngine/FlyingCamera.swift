import simd

class Input {
    var moveForward = false
    var moveBackward = false
    var moveLeft = false
    var moveRight = false
    var moveUp = false
    var moveDown = false
    var moveSpeed: Float = 5
    
    private var rotationInputDeltaX: Float = 0
    private var rotationInputDeltaY: Float = 0
    
    func setRotationInput(_ deltaX: Float, _ deltaY: Float) {
        self.rotationInputDeltaX = deltaX
        self.rotationInputDeltaY = deltaY
    }
    
    func getRotationInputDeltaX() -> Float {
        let result = rotationInputDeltaX
        rotationInputDeltaX = 0
        return result
    }
    
    func getRotationInputDeltaY() -> Float {
        let result = rotationInputDeltaY
        rotationInputDeltaY = 0
        return result
    }
}

class FlyingCamera: Camera {
    var input: Input
    
    init(input: Input, startPos: Float3 = Float3(0, 0, 0), degreesFov: Float = 45) {
        self.input = input
        super.init(startPos: startPos, degreesFov: degreesFov)
    }
    
    override func update(deltaTime: Float) {
        let viewDir = viewDirection
        let xzViewDir = normalize(Float2(viewDir.x, viewDir.z))
        
        let moveDistance = deltaTime * input.moveSpeed
        
        func moveOnXZ(direction: Float2) {
            position.z += moveDistance * direction.y
            position.x -= moveDistance * direction.x
        }
        
        if (input.moveLeft) {
            moveOnXZ(direction: turnCounterClockwise(xzViewDir))
        }
        if (input.moveRight) {
            moveOnXZ(direction: turnClockwise(xzViewDir))
        }
        if (input.moveForward) {
            moveOnXZ(direction: xzViewDir)
        }
        if (input.moveBackward) {
            moveOnXZ(direction: xzViewDir * -1)
        }
        
        if (input.moveDown) {
            position.y -= moveDistance
        }
        if (input.moveUp) {
            position.y += moveDistance
        }
        rotationY -= input.getRotationInputDeltaX() * deltaTime
        
        let newRotationX = rotationX - input.getRotationInputDeltaY() * deltaTime
        if (abs(newRotationX) < RIGHT_ANGLE_RADIANS) {
            rotationX = newRotationX
        }
    }
    
    private let RIGHT_ANGLE_RADIANS = toRadians(90)
}
