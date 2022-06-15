
func buildTestWorld() -> [BlockFace] {
    let generator = WorldGenerator()
    let positions = generateCircle(radiusChunks: 5)
    var chunks: [ChunkPos:Chunk] = [:]
    
    for pos in positions {
        chunks[pos] = generator.generateChunk(pos: pos)
    }
    var faces: [BlockFace] = []
    
    for (centerPos, centerChunk) in chunks {
        let northChunk = chunks[centerPos.move(.NORTH)]
        let westChunk = chunks[centerPos.move(.WEST)]
        
        faces.append(contentsOf: getBlockFaces(chunkPos: centerPos, chunk: centerChunk))

        if let northChunk = northChunk {
            faces.append(contentsOf: getNorthBorderBlockFaces(southChunkPos: centerPos,
                                                              southChunk: centerChunk,
                                                              northChunk: northChunk))
        }
        if let westChunk = westChunk {
            faces.append(contentsOf: getWestBorderBlockFaces(eastChunkPos: centerPos,
                                                             eastChunk: centerChunk,
                                                             westChunk: westChunk))
        }
    }
    
    return faces
}
