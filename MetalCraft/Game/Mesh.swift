import Metal

class Mesh {
    private var vertices: [Vertex]
    private var indices: [UInt16]
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    
    init(vertices: [Vertex], indices: [UInt16]) {
        self.vertices = vertices
        self.indices = indices
        
        createBuffers()
    }
    
    func createBuffers() {
        vertexBuffer = Engine.Device.makeBuffer(bytes: vertices,
                                                length: Vertex.size(vertices.count),
                                                options: [])
        
        indexBuffer = Engine.Device.makeBuffer(bytes: indices,
                                               length: UInt16.size(indices.count),
                                               options: [])
    }
    
    func render(_ encoder: MTLRenderCommandEncoder, instanceCount: Int) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indices.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0,
                                      instanceCount: instanceCount)
    }
}

