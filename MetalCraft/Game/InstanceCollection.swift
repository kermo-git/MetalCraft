import Metal

class InstanceCollection {
    private var mesh: Mesh
    private var instances: [Node] = []
    private var vConstantsBuffer: MTLBuffer!
    
    init(mesh: Mesh, instances: [Node]) {
        self.mesh = mesh
        self.instances = instances
        
        let bufferOptions = MTLResourceOptions.storageModeShared
        vConstantsBuffer = Engine.Device.makeBuffer(length: VertexConstants.size(instances.count),
                                                    options: bufferOptions)
    }
    
    func update(deltaTime: Float) {
        var vPointer = vConstantsBuffer.contents().bindMemory(to: VertexConstants.self, capacity: instances.count)
        for node in instances {
            vPointer.pointee = node.constants
            vPointer = vPointer.advanced(by: 1)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vConstantsBuffer, offset: 0, index: 1)
        mesh.render(encoder, instanceCount: instances.count)
    }
}
