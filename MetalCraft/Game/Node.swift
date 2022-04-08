import simd
import Metal

class Node {
    var position = Float3(0, 0, 0)
    var scaleFactor = Float3(1, 1, 1)
    var rotation = Float3(0, 0, 0)
    
    var modelMatrix: Float4x4 {
        return translate(dir: position) *
            rotateAroundZ(rotation.z) *
            rotateAroundY(rotation.y) *
            rotateAroundX(rotation.x) *
            scale(axis: scaleFactor)
    }
    
    var children: [Node] = []
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func update(deltaTime: Float) {
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        for child in children {
            child.render(encoder)
        }
        
        if let renderable = self as? Renderable {
            renderable.doRender(encoder)
        }
    }
}
