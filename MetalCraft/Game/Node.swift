import simd

class Node {
    var constants = VertexConstants()
    
    var position = Float3(0, 0, 0)
    var scaleFactor = Float3(1, 1, 1)
    var rotation = Float3(0, 0, 0)
    
    init(children: [Node] = [], textureType: TextureType = .ORANGE_BRICKS) {
        self.children = children
        constants.setTexture(textureType)
    }
    
    private var children: [Node]
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    var rotationMatrix: Float4x4 = matrix_identity_float4x4
    var modelMatrix: Float4x4 = matrix_identity_float4x4
    
    func updateMatrixes() {
        rotationMatrix = rotateAroundZ(rotation.z) *
                         rotateAroundY(rotation.y) *
                         rotateAroundX(rotation.x)
        
        modelMatrix = translate(dir: position) *
                      rotationMatrix *
                      scale(axis: scaleFactor)
    }
    
    func updateModel(deltaTime: Float) {}
    
    func update(deltaTime: Float,
                parentPVM: Float4x4 = matrix_identity_float4x4,
                parentRotation: Float4x4 = matrix_identity_float4x4) {
        
        updateModel(deltaTime: deltaTime)
        constants.projectionViewModel = parentPVM * modelMatrix
        constants.rotation = parentRotation * rotationMatrix
        
        for child in children {
            child.update(deltaTime: deltaTime,
                         parentPVM: constants.projectionViewModel,
                         parentRotation: constants.rotation)
        }
    }
}
