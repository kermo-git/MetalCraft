import simd

let RENDER_DISTANCE_CHUNKS = Float(8)
let RENDER_DISTANCE_BLOCKS = RENDER_DISTANCE_CHUNKS * Float(CHUNK_SIDE)
let MEMORY_DISTANCE_CHUNKS = Float(64)

private let localRenderCircle = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

actor ChunkLoader {
    var renderedChunks: [ChunkPos : RenderableChunk] = [:]
    
    private var memoryChunks: [ChunkPos : RenderableChunk] = [:]
    private var generationQueue: [ChunkPos] = localRenderCircle
    
    private var blocks: [BlockShaderInfo]
    private var generator: WorldGenerator
    
    init(blocks: [BlockShaderInfo], generator: WorldGenerator) {
        self.blocks = blocks
        self.generator = generator
    }
    
    func update(cameraPos: ChunkPos, posChanged: Bool) {
        if (posChanged) {
            for (pos, chunk) in memoryChunks {
                let distance = distance(pos, cameraPos)
                
                if (distance > MEMORY_DISTANCE_CHUNKS) {
                    memoryChunks.removeValue(forKey: pos)
                    renderedChunks.removeValue(forKey: pos)
                } else if (distance > RENDER_DISTANCE_CHUNKS) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
            }
            
            let globalRenderCircle = localRenderCircle.map {
                ChunkPos(X: cameraPos.X + $0.X,
                         Z: cameraPos.Z + $0.Z)
            }
            
            for pos in globalRenderCircle {
                if (memoryChunks[pos] == nil) {
                    generationQueue.append(pos)
                }
            }
        } else if (!generationQueue.isEmpty) {
            let pos = generationQueue.remove(at: 0)
            let distance = distance(pos, cameraPos)
            
            if (distance <= RENDER_DISTANCE_CHUNKS) {
                addChunk(pos: pos)
            }
        }
    }
    
    private func addChunk(pos: ChunkPos) {
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
    
    private func getSouthFaces(_ pos: ChunkPos, _ newChunk: Chunk) async -> Faces {
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
    
    private func getNorthFaces(_ pos: ChunkPos, _ newChunk: Chunk) async -> Faces {
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
    
    private func getWestFaces(_ pos: ChunkPos, _ newChunk: Chunk) async -> Faces {
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
    
    private func getEastFaces(_ pos: ChunkPos, _ newChunk: Chunk) async -> Faces {
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


private func generateCircle(radiusChunks: Int) -> [ChunkPos] {
    var result: [ChunkPos] = []
    
    func distanceFromCenter(_ pos: ChunkPos) -> Float {
        let fX = Float(pos.X)
        let fZ = Float(pos.Z)
        return sqrt(fX * fX + fZ * fZ)
    }
    
    for X in -radiusChunks...radiusChunks {
        for Z in -radiusChunks...radiusChunks {
            let pos = ChunkPos(X: X, Z: Z)
            
            if (distanceFromCenter(pos) <= Float(radiusChunks)) {
                result.append(pos)
            }
        }
    }
    
    return result.sorted() {
        distanceFromCenter($0) < distanceFromCenter($1)
    }
}
