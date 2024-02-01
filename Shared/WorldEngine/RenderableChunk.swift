import Metal

actor RenderableChunk {
    var pos: ChunkPos
    var data: Chunk
    var faces: Faces
    
    var vertexBuffer: MTLBuffer
    var vertexCount: Int
    
    init(pos: ChunkPos, data: Chunk, faces: Faces) {
        self.pos = pos
        self.data = data
        self.faces = faces
        
        let (vertexBuffer, vertexCount) = compile(pos: pos, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
    
    func addFaces(_ newFaces: Faces) {
        faces.append(newFaces)
        let (vertexBuffer, vertexCount) = compile(pos: pos, faces: faces)
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
    
    func getRenderData() -> (MTLBuffer, Int) {
        return (vertexBuffer, vertexCount)
    }
}

private func compile(pos: ChunkPos, faces: Faces) -> (MTLBuffer, Int) {
    var vertices: [Vertex] = []
    
    for (facePos, block) in faces {
        let globalPos = getGlobalPos(chunk: pos, local: facePos.blockPos)
        vertices.append(contentsOf: createVertices(pos: globalPos,
                                                   dir: facePos.direction,
                                                   block: block))
    }
    
    let buffer = Engine.device.makeBuffer(bytes: vertices,
                                          length: vertices.memorySize(),
                                          options: [])!
    return (buffer, vertices.count)
}
