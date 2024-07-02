import simd

let RENDER_DISTANCE_CHUNKS = 8
let MEMORY_DISTANCE_CHUNKS = 64

private let RENDER_DISTANCE_CHUNKS_SQUARED = RENDER_DISTANCE_CHUNKS * RENDER_DISTANCE_CHUNKS
private let MEMORY_DISTANCE_CHUNKS_SQUARED = MEMORY_DISTANCE_CHUNKS * MEMORY_DISTANCE_CHUNKS

private let localRenderCircle = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

actor ChunkLoader {
    var renderedChunks: [Int2 : RenderableChunk] = [:]
    
    private var memoryChunks: [Int2 : RenderableChunk] = [:]
    private var generationQueue: [Int2] = localRenderCircle
    
    private var blocks: [Block]
    private var generator: WorldGenerator
    
    init(blocks: [Block], generator: WorldGenerator) {
        self.blocks = blocks
        self.generator = generator
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
                
                if (d_sqr > MEMORY_DISTANCE_CHUNKS_SQUARED) {
                    memoryChunks.removeValue(forKey: pos)
                    renderedChunks.removeValue(forKey: pos)
                } else if (d_sqr > RENDER_DISTANCE_CHUNKS_SQUARED) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
            }
            
            let globalRenderCircle = localRenderCircle.map {
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
            
            if (d_sqr <= RENDER_DISTANCE_CHUNKS_SQUARED) {
                addChunk(pos: pos)
            }
        }
    }
    
    private func addChunk(pos: Int2) {
        Task {
            let newChunk = generator.generate(pos)
            
            async let topFaces = getBlockFaces(chunk: newChunk)
            async let northFaces = getNorthFaces(pos, newChunk)
            async let southFaces = getSouthFaces(pos, newChunk)
            async let westFaces = getWestFaces(pos, newChunk)
            async let eastFaces = getEastFaces(pos, newChunk)
            
            var faces = Faces()
            for sideFaces in await [topFaces, northFaces, southFaces, westFaces, eastFaces] {
                faces.append(sideFaces)
            }
            let newLoadedChunk = RenderableChunk(blocks: blocks, data: newChunk, faces: faces)
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
            await southChunk.addFaces(blocks: blocks,
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
            await northChunk.addFaces(blocks: blocks,
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
            await westChunk.addFaces(blocks: blocks,
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
            await eastChunk.addFaces(blocks: blocks,
                                     newFaces: eastChunkFaces)
            return newChunkFaces
        }
        return Faces()
    }
}


private func generateCircle(radiusChunks: Int) -> [Int2] {
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
