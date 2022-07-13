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
                generateChunk(pos: pos)
            }
        }
    }
    
    static func generateChunk(pos: ChunkPos) {
        let newChunk = worldGenerator.generateChunk(pos: pos)
        var faces = getBlockFaces(chunk: newChunk)
        
        let southPos = pos.move(.SOUTH)
        if let southChunk = memoryChunks[southPos] {
            let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(southChunk: southChunk.data,
                                                                            northChunk: newChunk)
            southChunk.faces.append(southChunkFaces)
            southChunk.reCompile(pos: southPos)
            faces.append(newChunkFaces)
        }
        let northPos = pos.move(.NORTH)
        if let northChunk = memoryChunks[northPos] {
            let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(southChunk: newChunk,
                                                                            northChunk: northChunk.data)
            northChunk.faces.append(northChunkFaces)
            northChunk.reCompile(pos: northPos)
            faces.append(newChunkFaces)
        }
        let westPos = pos.move(.WEST)
        if let westChunk = memoryChunks[westPos] {
            let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(eastChunk: newChunk,
                                                                          westChunk: westChunk.data)
            westChunk.faces.append(westChunkFaces)
            westChunk.reCompile(pos: westPos)
            faces.append(newChunkFaces)
        }
        let eastPos = pos.move(.EAST)
        if let eastChunk = memoryChunks[eastPos] {
            let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(eastChunk: eastChunk.data,
                                                                          westChunk: newChunk)
            eastChunk.faces.append(eastChunkFaces)
            eastChunk.reCompile(pos: eastPos)
            faces.append(newChunkFaces)
        }
        let newLoadedChunk = LoadedChunk(pos: pos, data: newChunk, faces: faces)
        renderedChunks[pos] = newLoadedChunk
        memoryChunks[pos] = newLoadedChunk
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
