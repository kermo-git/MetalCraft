import simd

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

actor ChunkLoader {
    var renderedChunks: [Int2 : RenderableChunk] = [:]
    
    private var memoryChunks: [Int2 : RenderableChunk] = [:]
    private var renderCircle: [Int2]
    private var generationQueue: [Int2]
    
    private var generator: WorldGenerator
    private var renderDistanceChunksSquared: Int
    private var memoryDistanceChunksSquared: Int
    
    init(generator: WorldGenerator,
         renderDistanceChunks: Int,
         memoryDistanceChunks: Int) {
        
        renderCircle = getChunkPosCircle(radiusChunks: Int(renderDistanceChunks))
        generationQueue = renderCircle
        
        self.generator = generator
        renderDistanceChunksSquared = renderDistanceChunks * renderDistanceChunks
        memoryDistanceChunksSquared = memoryDistanceChunks * memoryDistanceChunks
    }
    
    private func distance_squared(_ chunk1: Int2, _ chunk2: Int2) -> Int {
        let fX = chunk1.x - chunk2.x
        let fZ = chunk1.y - chunk2.y
        return fX * fX + fZ * fZ
    }
    
    func update(cameraPos: Int2, posChanged: Bool) {
        if (posChanged) {
            for (pos, chunk) in memoryChunks {
                let d_sqr = distance_squared(pos, cameraPos)
                
                if (d_sqr > memoryDistanceChunksSquared) {
                    memoryChunks.removeValue(forKey: pos)
                    renderedChunks.removeValue(forKey: pos)
                } else if (d_sqr > renderDistanceChunksSquared) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
            }
            
            let globalRenderCircle = renderCircle.map {
                Int2(x: cameraPos.x + $0.x,
                     y: cameraPos.y + $0.y)
            }
            
            for pos in globalRenderCircle {
                if (memoryChunks[pos] == nil) {
                    generationQueue.append(pos)
                }
            }
        } else if (!generationQueue.isEmpty) {
            let pos = generationQueue.remove(at: 0)
            let d_sqr = distance_squared(pos, cameraPos)
            
            if (d_sqr <= renderDistanceChunksSquared) {
                addChunk(pos: pos)
            }
        }
    }
    
    private func addChunk(pos: Int2) {
        Task {
            let newChunk = generator.generateChunk(pos)
            
            async let topFaces = getBlockFaces(chunk: newChunk)
            async let northFaces = getNorthFaces(pos, newChunk)
            async let southFaces = getSouthFaces(pos, newChunk)
            async let westFaces = getWestFaces(pos, newChunk)
            async let eastFaces = getEastFaces(pos, newChunk)
            
            var faces = Faces()
            for sideFaces in await [topFaces, northFaces, southFaces, westFaces, eastFaces] {
                faces.append(sideFaces)
            }
            let newLoadedChunk = RenderableChunk(blocks: generator.blocks, chunkPos: pos,
                                                 data: newChunk, faces: faces)
            memoryChunks[pos] = newLoadedChunk
            renderedChunks[pos] = newLoadedChunk
        }
    }
    
    private func getSouthFaces(_ pos: Int2, _ newChunk: Chunk) async -> Faces {
        let southPos = pos.move(.SOUTH)
        if let southChunk = memoryChunks[southPos] {
            let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(
                southChunk: await southChunk.data,
                northChunk: newChunk
            )
            await southChunk.addFaces(blocks: generator.blocks,
                                      newFaces: southChunkFaces)
            return newChunkFaces
        }
        return Faces()
    }
    
    private func getNorthFaces(_ pos: Int2, _ newChunk: Chunk) async -> Faces {
        let northPos = pos.move(.NORTH)
        if let northChunk = memoryChunks[northPos] {
            let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(
                southChunk: newChunk,
                northChunk: await northChunk.data
            )
            await northChunk.addFaces(blocks: generator.blocks,
                                      newFaces: northChunkFaces)
            return newChunkFaces
        }
        return Faces()
    }
    
    private func getWestFaces(_ pos: Int2, _ newChunk: Chunk) async -> Faces {
        let westPos = pos.move(.WEST)
        if let westChunk = memoryChunks[westPos] {
            let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(
                eastChunk: newChunk,
                westChunk: await westChunk.data
            )
            await westChunk.addFaces(blocks: generator.blocks,
                                     newFaces: westChunkFaces)
            return newChunkFaces
        }
        return Faces()
    }
    
    private func getEastFaces(_ pos: Int2, _ newChunk: Chunk) async -> Faces {
        let eastPos = pos.move(.EAST)
        if let eastChunk = memoryChunks[eastPos] {
            let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(
                eastChunk: await eastChunk.data,
                westChunk: newChunk
            )
            await eastChunk.addFaces(blocks: generator.blocks,
                                     newFaces: eastChunkFaces)
            return newChunkFaces
        }
        return Faces()
    }
}


private func getChunkPosCircle(radiusChunks: Int) -> [Int2] {
    var result: [Int2] = []
    
    for X in -radiusChunks...radiusChunks {
        for Z in -radiusChunks...radiusChunks {
            let pos = Int2(X, Z)
            
            if (simd_length(Float2(pos)) <= Float(radiusChunks)) {
                result.append(pos)
            }
        }
    }
    
    return result.sorted() {
        simd_length(Float2($0)) < simd_length(Float2($1))
    }
}
