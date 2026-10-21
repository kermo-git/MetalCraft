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
                        chunkPos: Int2) -> [BlockFace] {
        var vertices: [BlockFace] = []
        
        for (localBlockPos, directions) in faces {
            let (blockID, orientation) = data.get(localBlockPos)
            let block = blocks[Int(blockID)]
            let globalBlockPos = getGlobalBlockPos(chunkPos: chunkPos,
                                                   localBlockPos: localBlockPos)
            vertices.append(
                contentsOf:
                    block.createVertexShaderData(
                        pos: globalBlockPos,
                        orientation: orientation,
                        directions: directions
                    )
            )
        }
        return vertices
    }
}
