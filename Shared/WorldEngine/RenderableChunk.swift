import Metal

actor RenderableChunk {
    var data: Chunk
    var faces: Faces
    
    init(data: Chunk, faces: Faces) {
        self.data = data
        self.faces = faces
    }
    
    func addFaces(newFaces: Faces) {
        faces.append(newFaces)
    }
    
    func createVertices(blocks: [Block],
                        chunkPos: Int2) -> [Quad] {
        var vertices: [Quad] = []
        
        for (localBlockPos, directions) in faces {
            let (blockID, rotation) = data.get(localBlockPos)
            let block = blocks[Int(blockID)]
            let globalBlockPos = getGlobalBlockPos(chunkPos: chunkPos,
                                                   localBlockPos: localBlockPos)
            vertices.append(
                contentsOf:
                    block.createVertexShaderData(
                        pos: globalBlockPos,
                        rotation: rotation,
                        directions: directions
                    )
            )
        }
        return vertices
    }
}
