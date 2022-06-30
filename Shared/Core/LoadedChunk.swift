import Metal

class LoadedChunk {
    var data: Chunk
    var faces: [BlockFace]
    var buffer: MTLBuffer
    
    init(data: Chunk, faces: [BlockFace]) {
        self.data = data
        self.faces = faces
        buffer = toBuffer(faces)
    }
}

func toBuffer(_ faces: [BlockFace]) -> MTLBuffer {
    let bufferOptions = MTLResourceOptions.storageModeShared
    let result = Engine.Device.makeBuffer(length: ShaderBlockFace.size(faces.count),
                                          options: bufferOptions)
    
    var pointer = result!.contents().bindMemory(to: ShaderBlockFace.self, capacity: faces.count)
    
    for face in faces {
        pointer.pointee = toShaderData(face)
        pointer = pointer.advanced(by: 1)
    }
    return result!
}

func toShaderData(_ face: BlockFace) -> ShaderBlockFace {
    var constants = ShaderBlockFace()
    constants.modelMatrix = getModelMatrix(face: face)
    constants.setTexture(face.textureType)
    return constants
}
