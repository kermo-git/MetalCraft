import Darwin

let RENDER_DISTANCE_CHUNKS = 8
let RENDER_DISTANCE = Float(RENDER_DISTANCE_CHUNKS * CHUNK_SIDE)
let BACKGROUND_COLOR = Float4(x: 0.075,
                              y: 0.78,
                              z: 0.95,
                              w: 1)
let MEMORY_DISTANCE_CHUNKS = 64

let localRenderCircle: [ChunkPos] = generateCircle(radiusChunks: RENDER_DISTANCE_CHUNKS)

enum WorldState {
    static var worldGenerator = WorldGenerator()
    
    static var playerChunkPos: ChunkPos = getChunkPos(Player.position)
    
    static var memoryChunks: [ChunkPos : LoadedChunk] = [:]
    static var renderedChunks: [ChunkPos : LoadedChunk] = [:]
    static var toBeGenerated: [ChunkPos] = localRenderCircle
    
    static func update(deltaTime: Float) {
        let newPlayerChunkPos = getChunkPos(Player.position)
        
        if (playerChunkPos != newPlayerChunkPos) {
            for (pos, chunk) in memoryChunks {
                let distanceFromPlayer = distance(pos, newPlayerChunkPos)
                
                if (distanceFromPlayer > Float(RENDER_DISTANCE_CHUNKS)) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
                if (distanceFromPlayer > Float(MEMORY_DISTANCE_CHUNKS)) {
                    memoryChunks.removeValue(forKey: pos)
                }
            }
            
            let globalRenderCircle = localRenderCircle.map {
                ChunkPos(X: newPlayerChunkPos.X + $0.X,
                         Z: newPlayerChunkPos.Z + $0.Z)
            }
            
            for pos in globalRenderCircle {
                if (memoryChunks[pos] == nil) {
                    toBeGenerated.append(pos)
                }
            }
            playerChunkPos = newPlayerChunkPos
        }
        if (!toBeGenerated.isEmpty) {
            let pos = toBeGenerated.remove(at: 0)
            let distanceFromPlayer = distance(pos, newPlayerChunkPos)
            
            if (distanceFromPlayer <= Float(RENDER_DISTANCE_CHUNKS)) {
                let newChunk = worldGenerator.generateChunk(pos: pos)
                var faces = getBlockFaces(chunkPos: pos, chunk: newChunk)
                
                let southPos = pos.move(.SOUTH)
                if let southChunk = memoryChunks[southPos] {
                    faces.append(
                        contentsOf: getNorthBorderBlockFaces(
                            southChunkPos: southPos,
                            southChunk: southChunk.data,
                            northChunk: newChunk
                        )
                    )
                }
                let northPos = pos.move(.NORTH)
                if let northChunk = memoryChunks[northPos] {
                    faces.append(
                        contentsOf: getNorthBorderBlockFaces(
                            southChunkPos: pos,
                            southChunk: newChunk,
                            northChunk: northChunk.data
                        )
                    )
                }
                let westPos = pos.move(.WEST)
                if let westChunk = memoryChunks[westPos] {
                    faces.append(
                        contentsOf: getWestBorderBlockFaces(
                            eastChunkPos: pos,
                            eastChunk: newChunk,
                            westChunk: westChunk.data
                        )
                    )
                }
                let eastPos = pos.move(.EAST)
                if let eastChunk = memoryChunks[eastPos] {
                    faces.append(
                        contentsOf: getWestBorderBlockFaces(
                            eastChunkPos: eastPos,
                            eastChunk: eastChunk.data,
                            westChunk: newChunk
                        )
                    )
                }
                let newLoadedChunk = LoadedChunk(data: newChunk, faces: faces)
                renderedChunks[pos] = newLoadedChunk
                memoryChunks[pos] = newLoadedChunk
            }
        }
    }
}

func generateCircle(radiusChunks: Int) -> [ChunkPos] {
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
