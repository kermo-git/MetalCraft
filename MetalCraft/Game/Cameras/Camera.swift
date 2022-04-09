
enum CameraType {
    case DebugCamera
}

protocol Camera {
    var type: CameraType { get }
    var position: Float3 { get set }
    func update(deltaTime: Float)
}

extension Camera {
    var viewMatrix: Float4x4 {
        return translate(dir: -position)
    }
}
