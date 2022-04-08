import Metal

class GameObject: Node {
    var constants = ModelConstants()
    var mesh: Mesh!
    
    init(meshType: MeshType) {
        mesh = MeshLibrary.Mesh(meshType)
    }
    
    override func update(deltaTime: Float) {
        constants.modelMatrix = self.modelMatrix
    }
}

extension GameObject: Renderable {
    func doRender(_ encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(&constants, length: ModelConstants.size(), index: 1)
        encoder.setRenderPipelineState(RenderPipelineStateLibrary.get(.Basic))
        encoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: mesh.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: mesh.indexBuffer,
                                      indexBufferOffset: 0)
    }
}
