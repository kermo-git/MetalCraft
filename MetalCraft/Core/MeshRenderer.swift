import Metal

class MeshRenderer {
    private var mesh: Mesh
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    
    init(mesh: Mesh) {
        self.mesh = mesh
        vertexBuffer = Engine.Device.makeBuffer(bytes: mesh.vertices,
                                                length: Vertex.size(mesh.vertices.count),
                                                options: [])
        
        indexBuffer = Engine.Device.makeBuffer(bytes: mesh.indices,
                                               length: UInt16.size(mesh.indices.count),
                                               options: [])
    }
    
    func render(_ encoder: MTLRenderCommandEncoder, instanceCount: Int) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: mesh.indices.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0,
                                      instanceCount: instanceCount)
    }
}
