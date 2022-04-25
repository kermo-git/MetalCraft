import Metal

class BlockRenderer {
    private var meshRenderer = MeshRenderer(mesh: buildQuad())
    private var instanceCount = 0
    private var vConstantsBuffer: MTLBuffer!
    
    func setFaces(faces: [BlockFace]) {
        instanceCount = faces.count
        
        let bufferOptions = MTLResourceOptions.storageModeShared
        vConstantsBuffer = Engine.Device.makeBuffer(length: FaceConstants.size(instanceCount),
                                                    options: bufferOptions)
        
        var vPointer = vConstantsBuffer.contents().bindMemory(to: FaceConstants.self, capacity: instanceCount)
        
        for node in faces {
            var constants = FaceConstants()
            constants.modelMatrix = getModelMatrix(face: node)
            constants.normal = getNormal(node.direction)
            constants.setTexture(node.textureType)
            vPointer.pointee = constants
            vPointer = vPointer.advanced(by: 1)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vConstantsBuffer, offset: 0, index: 2)
        meshRenderer.render(encoder, instanceCount: instanceCount)
    }
}
