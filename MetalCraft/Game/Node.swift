import simd
import Metal

class Node {
    var mesh: Mesh
    private var children: [Node] = []
    var constants = ShaderConstants()
    
    init(mesh: Mesh) {
        self.mesh = mesh
    }
    
    var position = Float3(0, 0, 0)
    var scaleFactor = Float3(1, 1, 1)
    var rotation = Float3(0, 0, 0)
    
    private var modelMatrix: Float4x4 {
        return translate(dir: position) *
            rotateAroundZ(rotation.z) *
            rotateAroundY(rotation.y) *
            rotateAroundX(rotation.x) *
            scale(axis: scaleFactor)
    }
    
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    func updateModel(deltaTime: Float) {}
    
    func update(deltaTime: Float, parentMatrix: Float4x4 = matrix_identity_float4x4) {
        updateModel(deltaTime: deltaTime)
        constants.projectionViewModel = parentMatrix * self.modelMatrix
        
        for child in children {
            child.update(deltaTime: deltaTime, parentMatrix: constants.projectionViewModel)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        for child in children {
            child.render(encoder)
        }
        renderMesh(encoder)
    }
    
    private func renderMesh(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(Engine.RenderPipelineState)
        encoder.setDepthStencilState(Engine.DepthPencilState)
        
        encoder.setVertexBytes(&constants, length: ShaderConstants.size(), index: 2)
        encoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: mesh.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: mesh.indexBuffer,
                                      indexBufferOffset: 0)
    }
}
