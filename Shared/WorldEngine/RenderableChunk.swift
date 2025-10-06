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
                        chunkPos: Int2) -> [Vertex] {
        var vertices: [Vertex] = []
        
        for (localBlockPos, directions) in faces {
            let (blockID, orientation) = data.get(localBlockPos)
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
        return vertices
    }
}

func createVertexBuffer(device: MTLDevice, vertices: [Vertex]) -> MTLBuffer {
    return device.makeBuffer(bytes: vertices,
                             length: vertices.memorySize(),
                             options: [])!
}
