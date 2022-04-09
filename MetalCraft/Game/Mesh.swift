import Metal

class Mesh {
    var vertices: [Vertex]
    var indices: [UInt16]
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    var vertexCount: Int! {
        vertices.count
    }
    var indexCount: Int! {
        indices.count
    }
    
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
}

