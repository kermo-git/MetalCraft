import simd
import Metal

class Node {
    var position = Float3(0, 0, 0)
    var axisScale = Float3(1, 1, 1)
    var rotation = Float3(0, 0, 0)
    
    var modelMatrix: Float4x4 {
        return translate(dir: position) *
            rotateAroundZ(rotation.z) *
            rotateAroundY(rotation.y) *
            rotateAroundX(rotation.x) *
            scale(axis: axisScale)
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        let renderable = self as? Renderable
        
        if (renderable != nil) {
            renderable?.doRender(encoder)
        }
    }
}
