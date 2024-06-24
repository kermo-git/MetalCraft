import simd

class Camera {
    var position: Float3
    
    var rotationX: Float = 0
    var rotationY: Float = 0
    var degreesFov: Float
    
    init(startPos: Float3 = Float3(0, 0, 0), degreesFov: Float = 45) {
        self.position = startPos
        self.degreesFov = degreesFov
    }
    
    var viewDirection: Float3 {
        let rotation = rotateAroundY(rotationY) * rotateAroundX(rotationX)
        let result4 = rotation * Float4(0, 0, -1, 1)
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
