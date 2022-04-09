
class CameraManager {
    var currentCamera: Camera!
    private var cameras: [CameraType : Camera] = [:]
    
    func addCamera(_ camera: Camera, _ isCurrent: Bool = true) {
        cameras.updateValue(camera, forKey: camera.type)
        if (isCurrent) {
            setCamera(camera.type)
        }
    }
    
    func setCamera(_ type: CameraType) {
        currentCamera = cameras[type]!
    }
    
    func update(deltaTime: Float) {
        for camera in cameras.values {
            camera.update(deltaTime: deltaTime)
        }
    }
}
