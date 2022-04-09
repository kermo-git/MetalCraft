import simd
import Metal

class Scene {
    private var children: [Node] = []
    var camera: Camera!
    
    init() {
        buildScene()
    }
    
    func buildScene() {}
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

        for node in children {
            node.update(deltaTime: deltaTime, parentMatrix: camera.projectionViewMatrix)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        for node in children {
            node.render(encoder)
        }
    }
}
