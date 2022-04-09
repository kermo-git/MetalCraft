import simd

protocol Camera {
    var projectionMatrix: Float4x4 { get }
    
    var rotationX: Float { get set }
    var rotationY: Float { get set }
    var position: Float3 { get set }

    func update(deltaTime: Float)
}

extension Camera {
    var viewMatrix: Float4x4 {
        return rotateAroundX(-rotationX) *
               rotateAroundY(-rotationY) *
               translate(dir: -position)
    }
    var projectionViewMatrix: Float4x4 {
        return projectionMatrix * viewMatrix
    }
}
