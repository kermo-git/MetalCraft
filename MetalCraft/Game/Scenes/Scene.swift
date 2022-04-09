import Metal

class Scene: Node {
    var constants = SceneConstants()
    var cameraManager = CameraManager()
    
    override init() {
        super.init()
        buildScene()
    }
    
    func buildScene() {}
    
    override func update(deltaTime: Float) {
        cameraManager.update(deltaTime: deltaTime)
        constants.viewMatrix = cameraManager.currentCamera.viewMatrix
        super.update(deltaTime: deltaTime)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(&constants, length: SceneConstants.size(), index: 1)
        super.render(encoder)
    }
}
