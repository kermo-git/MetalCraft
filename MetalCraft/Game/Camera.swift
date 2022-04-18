import simd

class Camera {
    var rotationX: Float = 0
    var rotationY: Float = 0
    var position: Float3 = Float3(0, 0, 0)
    
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    var viewMatrix: Float4x4 = matrix_identity_float4x4
    var projectionViewMatrix: Float4x4 = matrix_identity_float4x4
    
    init() {
        updateProjectionMatrix(aspectRatio: Renderer.aspectRatio)
    }
    
    var viewDirection: Float3 {
        let rotation = rotateAroundY(rotationY) * rotateAroundX(rotationX)
        let result4 = Float4(0, 0, -1, 1) * rotation
        return Float3(result4.x, result4.y, result4.z)
    }
    
    func updateProjectionMatrix(aspectRatio: Float) {}
    
    func updateProjectionViewMatrix() {
        viewMatrix = rotateAroundX(-rotationX) *
                     rotateAroundY(-rotationY) *
                     translate(dir: -position)
        projectionViewMatrix = projectionMatrix * viewMatrix
    }

    func update(deltaTime: Float) {}
}
