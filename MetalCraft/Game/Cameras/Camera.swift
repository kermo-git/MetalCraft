import simd

enum CameraType {
    case DebugCamera
}

protocol Camera {
    var type: CameraType { get }
    var position: Float3 { get set }
    var rotation: Float3 { get set }
    var projectionMatrix: Float4x4 { get }
    func update(deltaTime: Float)
}

extension Camera {
    var viewMatrix: Float4x4 {
        return rotateAroundX(-rotation.x) *
               rotateAroundY(-rotation.y) *
               rotateAroundZ(-rotation.z) *
               translate(dir: -position)
    }
}
