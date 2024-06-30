import Metal

actor RenderableChunk {
    var data: Chunk
    var faces: Faces
    
    var vertexBuffer: MTLBuffer
    var vertexCount: Int
    
    init(blocks: [Block], data: Chunk, faces: Faces) {
        self.data = data
        self.faces = faces
        
        let (vertexBuffer, vertexCount) = compileChunk(blocks: blocks, chunk: data, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
    
    func addFaces(blocks: [Block], newFaces: Faces) {
        faces.append(newFaces)
        let (vertexBuffer, vertexCount) = compileChunk(blocks: blocks, chunk: data, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
}

private func compileChunk(blocks: [Block],
                          chunk: Chunk, faces: Faces) -> (MTLBuffer, Int) {
    var vertices: [Vertex] = []
    
    for (localPos, directions) in faces {
        let orientedBlock = chunk[localPos]
        let block = blocks[orientedBlock.blockID]
        let globalPos = getGlobalPos(chunk: chunk.pos, local: localPos)
        
        vertices.append(
            contentsOf:
                block.getVertices(
                    pos: globalPos,
                    orientation: orientedBlock.orientation,
                    directions: directions
                )
        )
    }
    
    let buffer = Engine.device.makeBuffer(bytes: vertices,
                                          length: vertices.memorySize(),
                                          options: [])!
    return (buffer, vertices.count)
}
