import Metal

class InstanceCollection {
    private var mesh: Mesh
    private var instances: [Node] = []
    
    private var instanceCount: Int
    private var vConstantsBuffer: MTLBuffer!
    
    init(mesh: Mesh, instances: [Node]) {
        self.mesh = mesh
        self.instances = instances
        
        instanceCount = instances.count
        vConstantsBuffer = Engine.Device.makeBuffer(length: VertexConstants.size(instanceCount), options: [])
    }
    
    func update(deltaTime: Float) {
        var vPointer = vConstantsBuffer.contents().bindMemory(to: VertexConstants.self, capacity: instanceCount)
        for node in instances {
            vPointer.pointee = node.constants
            vPointer = vPointer.advanced(by: 1)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {        
        encoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(vConstantsBuffer, offset: 0, index: 1)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: mesh.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: mesh.indexBuffer,
                                      indexBufferOffset: 0,
                                      instanceCount: instanceCount)
    }
}
