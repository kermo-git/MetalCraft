import simd

class Camera {    
    var rotationX: Float = 0
    var rotationY: Float = 0
    var position: Float3 = Float3(0, 0, 0)
    var degreesFov: Float = 45
    
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
        // Override in subclass
    }
}
