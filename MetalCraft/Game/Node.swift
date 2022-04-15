import simd
import Metal

class Node {
    var position = Float3(0, 0, 0)
    var scaleFactor = Float3(1, 1, 1)
    var rotation = Float3(0, 0, 0)
    var textureIdx: Int = 0
    
    func buildModelMatrix() -> Float4x4 {
        return translate(dir: position) *
            rotateAroundZ(rotation.z) *
            rotateAroundY(rotation.y) *
            rotateAroundX(rotation.x) *
            scale(axis: scaleFactor)
    }
    
    var constants = VertexConstants()
    var children: [Node] = []
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func updateModel(deltaTime: Float) {}
    
    func update(deltaTime: Float, parentMatrix: Float4x4 = matrix_identity_float4x4) {
        updateModel(deltaTime: deltaTime)
        constants.projectionViewModel = parentMatrix * buildModelMatrix()
        constants.textureIdx = textureIdx
        
        for child in children {
            child.update(deltaTime: deltaTime, parentMatrix: constants.projectionViewModel)
        }
    }
}
