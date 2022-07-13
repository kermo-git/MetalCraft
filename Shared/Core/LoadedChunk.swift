import Metal

class LoadedChunk {
    var data: Chunk
    var faces: Faces
    var vertexBuffer: MTLBuffer!
    
    init(pos: ChunkPos, data: Chunk, faces: Faces) {
        self.data = data
        self.faces = faces
        reCompile(pos: pos)
    }
    
    func reCompile(pos: ChunkPos) {
        vertexBuffer = compile(chunkPos: pos, faces: faces)
    }
}

func compile(chunkPos: ChunkPos, faces: Faces) -> MTLBuffer {
    var vertices: [Vertex] = []
    
    for (facePos, textureType) in faces {
        let globalPos = getGlobalPos(chunk: chunkPos, local: facePos.blockPos)
        vertices.append(contentsOf: createVertices(pos: globalPos,
                                                   dir: facePos.direction,
                                                   texture: textureType))
    }
    
    return Engine.Device.makeBuffer(bytes: vertices,
                                    length: Vertex.size(vertices.count),
                                    options: [])!
}
