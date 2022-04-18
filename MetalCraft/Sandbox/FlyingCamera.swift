import simd

class FlyingCamera: Camera {
    let flySpeed: Float = 5
    let mouseSpeed: Float = 0.005
    
    var xzViewDir: Float2 {
        let viewDir = self.viewDirection
        return normalize(Float2(viewDir.x, viewDir.z))
    }
    
    override func updateProjectionMatrix(aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: 45,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
        self.updateProjectionViewMatrix()
    }
    
    override func update(deltaTime: Float) {
        let inc = deltaTime * flySpeed
        
        func moveOnXZ(direction: Float2) {
            position.z += inc * direction.y
            position.x -= inc * direction.x
        }
        
        let _xzViewDir = xzViewDir
        
        if (Keyboard.isKeyPressed(.A)) {
            moveOnXZ(direction: turnCounterClockwise(_xzViewDir))
        }
        if (Keyboard.isKeyPressed(.D)) {
            moveOnXZ(direction: turnClockwise(_xzViewDir))
        }
        if (Keyboard.isKeyPressed(.W)) {
            moveOnXZ(direction: _xzViewDir)
        }
        if (Keyboard.isKeyPressed(.S)) {
            moveOnXZ(direction: _xzViewDir * -1)
        }
        
        if (Keyboard.isKeyPressed(.SHIFT)) {
            position.y -= inc
        }
        if (Keyboard.isKeyPressed(.SPACE)) {
            position.y += inc
        }
        rotationY -= Mouse.getPositionDeltaX() * mouseSpeed
        rotationX -= Mouse.getPositionDeltaY() * mouseSpeed
        
        updateProjectionViewMatrix()
    }
}

