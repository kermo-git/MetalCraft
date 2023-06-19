import Darwin

let RENDER_DISTANCE_CHUNKS = Float(8)
let RENDER_DISTANCE = RENDER_DISTANCE_CHUNKS * Float(CHUNK_SIDE)
let BACKGROUND_COLOR = Float4(x: 0.075,
                              y: 0.78,
                              z: 0.95,
                              w: 1)
let MEMORY_DISTANCE_CHUNKS = Float(64)

let localRenderCircle: [ChunkPos] = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))

class ChunkLoader {
    var cameraChunkPos: ChunkPos
    var memoryChunks: [ChunkPos : LoadedChunk] = [:]
    var renderedChunks: [ChunkPos : LoadedChunk] = [:]
    var toBeGenerated: [ChunkPos] = localRenderCircle
    
    var generator: (_ pos: ChunkPos) -> Chunk
    
    init(cameraStartPos: Float3, generator: @escaping (_ pos: ChunkPos) -> Chunk) {
        self.cameraChunkPos = getChunkPos(cameraStartPos)
        self.generator = generator
    }
    
    func update(cameraPos: Float3) {
        let newPlayerChunkPos = getChunkPos(cameraPos)
        
        if (cameraChunkPos != newPlayerChunkPos) {
            for (pos, chunk) in memoryChunks {
                let distanceFromPlayer = distance(pos, newPlayerChunkPos)
                
                if (distanceFromPlayer > RENDER_DISTANCE_CHUNKS) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
                if (distanceFromPlayer > MEMORY_DISTANCE_CHUNKS) {
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
            cameraChunkPos = newPlayerChunkPos
        }
        if (!toBeGenerated.isEmpty) {
            let pos = toBeGenerated.remove(at: 0)
            let distanceFromPlayer = distance(pos, newPlayerChunkPos)
            
            if (distanceFromPlayer <= RENDER_DISTANCE_CHUNKS) {
                // addChunk(pos: pos, newChunk: generateChunk(pos: pos))
                // This makes the game faster, but may occasionally crash:
                Task {
                    addChunk(pos: pos, newChunk: generateChunk(pos: pos))
                }
            }
        }
    }
    
    func addChunk(pos: ChunkPos, newChunk: Chunk) {
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
