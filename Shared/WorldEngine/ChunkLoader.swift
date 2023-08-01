import simd

let RENDER_DISTANCE_CHUNKS = Float(8)
let RENDER_DISTANCE_BLOCKS = RENDER_DISTANCE_CHUNKS * Float(CHUNK_SIDE)
let MEMORY_DISTANCE_CHUNKS = Float(64)

private let localRenderCircle: [ChunkPos] = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

actor ChunkLoader {
    var renderedChunks: [ChunkPos : RenderableChunk] = [:]
    
    private var memoryChunks: [ChunkPos : RenderableChunk] = [:]
    private var generationQueue: [ChunkPos] = localRenderCircle
    private var generator: (_ pos: ChunkPos) -> Chunk
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk) {
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
                addChunk(pos: pos, newChunk: generator(pos))
            }
        }
    }
    
    func addChunk(pos: ChunkPos, newChunk: Chunk) {
        @Sendable func getTopFaces() async -> Faces {
            return getBlockFaces(chunk: newChunk)
        }
        @Sendable func getSouthFaces() async -> Faces {
            let southPos = pos.move(.SOUTH)
            if let southChunk = await memoryChunks[southPos] {
                let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(southChunk: await southChunk.data,
                                                                                northChunk: newChunk)
                await southChunk.addFaces(southChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getNorthFaces() async -> Faces {
            let northPos = pos.move(.NORTH)
            if let northChunk = await memoryChunks[northPos] {
                let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(southChunk: newChunk,
                                                                                northChunk: await northChunk.data)
                await northChunk.addFaces(northChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getWestFaces() async -> Faces {
            let westPos = pos.move(.WEST)
            if let westChunk = await memoryChunks[westPos] {
                let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(eastChunk: newChunk,
                                                                              westChunk: await westChunk.data)
                await westChunk.addFaces(westChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getEastFaces() async -> Faces {
            let eastPos = pos.move(.EAST)
            if let eastChunk = await memoryChunks[eastPos] {
                let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(eastChunk: await eastChunk.data,
                                                                              westChunk: newChunk)
                await eastChunk.addFaces(eastChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        
        Task {
            async let topFaces = getTopFaces()
            async let northFaces = getNorthFaces()
            async let southFaces = getSouthFaces()
            async let westFaces = getWestFaces()
            async let eastFaces = getEastFaces()
            
            var faces = Faces()
            for sideFaces in await [topFaces, northFaces, southFaces, westFaces, eastFaces] {
                faces.append(sideFaces)
            }
            let newLoadedChunk = RenderableChunk(pos: pos, data: newChunk, faces: faces)
            memoryChunks[pos] = newLoadedChunk
            renderedChunks[pos] = newLoadedChunk
        }
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
