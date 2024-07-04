import Metal

actor RenderableChunk {
    var chunkPos: Int2
    var data: Chunk
    var faces: Faces
    
    var vertexBuffer: MTLBuffer
    var vertexCount: Int
    
    init(blocks: [Block], chunkPos: Int2,
         data: Chunk, faces: Faces) {
        self.chunkPos = chunkPos
        self.data = data
        self.faces = faces
        
        let (vertexBuffer, vertexCount) = compileChunk(blocks: blocks, chunkPos: chunkPos,
                                                       chunk: data, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
    
    func addFaces(blocks: [Block], newFaces: Faces) {
        faces.append(newFaces)
        let (vertexBuffer, vertexCount) = compileChunk(blocks: blocks, chunkPos: chunkPos,
                                                       chunk: data, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
}

private func compileChunk(blocks: [Block], chunkPos: Int2,
                          chunk: Chunk, faces: Faces) -> (MTLBuffer, Int) {
    var vertices: [Vertex] = []
    
    for (localBlockPos, directions) in faces {
        let (blockID, orientation) = chunk.get(localBlockPos)
        let block = blocks[blockID]
        let globalBlockPos = getGlobalBlockPos(chunkPos: chunkPos, 
                                               localBlockPos: localBlockPos)
        vertices.append(
            contentsOf:
                block.getVertices(
                    pos: globalBlockPos,
                    orientation: orientation,
                    directions: directions
                )
        )
    }
    
    let buffer = Engine.device.makeBuffer(bytes: vertices,
                                          length: vertices.memorySize(),
                                          options: [])!
    return (buffer, vertices.count)
}
