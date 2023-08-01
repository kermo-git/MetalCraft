import simd

class FlyingCamera: Camera {
    let flySpeed: Float = 5
    let rotateSpeed: Float = 0.005
    
    init(startPos: Float3) {
        super.init()
        self.position = startPos
    }
    
    override func update(deltaTime: Float) {
        let viewDir = viewDirection
        let xzViewDir = normalize(Float2(viewDir.x, viewDir.z))
        
        let inc = deltaTime * flySpeed
        
        func moveOnXZ(direction: Float2) {
            position.z += inc * direction.y
            position.x -= inc * direction.x
        }
        
        if (Input.moveLeft) {
            moveOnXZ(direction: turnCounterClockwise(xzViewDir))
        }
        if (Input.moveRight) {
            moveOnXZ(direction: turnClockwise(xzViewDir))
        }
        if (Input.moveForward) {
            moveOnXZ(direction: xzViewDir)
        }
        if (Input.moveBackward) {
            moveOnXZ(direction: xzViewDir * -1)
        }
        
        if (Input.flyDown) {
            position.y -= inc
        }
        if (Input.flyUp) {
            position.y += inc
        }
        rotationY -= Input.getCamRotationX() * rotateSpeed
        rotationX -= Input.getCamRotationY() * rotateSpeed
    }
}
