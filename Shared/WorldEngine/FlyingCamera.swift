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
        let moveDistance = deltaTime * input.moveSpeed
        
        func moveOnXZ(_ x: Float, _ z: Float) {
            position.x += moveDistance * x
            position.z += moveDistance * z
        }
        
        let viewDirX = -sin(rotationY)
        let viewDirZ = -cos(rotationY)
        
        if (input.moveLeft) {
            moveOnXZ(viewDirZ, -viewDirX)
        }
        if (input.moveRight) {
            moveOnXZ(-viewDirZ, viewDirX)
        }
        if (input.moveForward) {
            moveOnXZ(viewDirX, viewDirZ)
        }
        if (input.moveBackward) {
            moveOnXZ(-viewDirX, -viewDirZ)
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
