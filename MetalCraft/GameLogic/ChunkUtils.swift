
let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256

let BLOCKS_IN_SLICE_YZ = CHUNK_SIDE * CHUNK_HEIGHT
let BLOCKS_IN_CHUNK = BLOCKS_IN_SLICE_YZ * CHUNK_SIDE

struct Chunk {
    var data: [Block] = Array(repeating: .AIR, count: BLOCKS_IN_CHUNK)
    
    private func getIndex(_ pos: BlockPos) -> Int {
        return pos.X * BLOCKS_IN_SLICE_YZ + pos.Y * CHUNK_SIDE + pos.Z
    }
    
    subscript(_ pos: BlockPos) -> Block {
        get {
            return data[getIndex(pos)]
        }
        set {
            data[getIndex(pos)] = newValue
        }
    }
}

class ChunkMap {
    var chunks: [String : Chunk] = [:]
    
    private func getKey(_ chunkX: Int, _ chunkZ: Int) -> String {
        return String(chunkX) + "_" + String(chunkZ)
    }
    
    subscript(_ pos: ChunkPos) -> Chunk? {
        get {
            return chunks[getKey(pos.X, pos.Z)]
        }
        set {
            chunks[getKey(pos.X, pos.Z)] = newValue
        }
    }
}

func getNorthBorderBlockFaces(southChunkPos: ChunkPos,
                              southChunk: Chunk,
                              northChunk: Chunk) -> [BlockFace] {
    
    var faces: [BlockFace] = []
    
    let southLocalZ = 0
    let northLocalZ = CHUNK_SIDE - 1
    
    let northChunkPos = southChunkPos.move(.NORTH)
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in 0..<CHUNK_HEIGHT {
            
            let southBlockPos = BlockPos(X: localX, Y: globalY, Z: southLocalZ)
            let northBlockPos = BlockPos(X: localX, Y: globalY, Z: northLocalZ)
            
            switch southChunk[southBlockPos] {
                case .AIR:
                    switch northChunk[northBlockPos] {
                        case .AIR:
                            break
                        case .SOLID_BLOCK(_, let sideTexture, _):
                            let globalPos = toGlobalPos(chunk: northChunkPos,
                                                        local: northBlockPos)
                        
                            faces.append(BlockFace(direction: .SOUTH,
                                                   textureType: sideTexture,
                                                   pos: globalPos))
                    }
                case .SOLID_BLOCK(_, let sideTexture, _):
                    switch northChunk[northBlockPos] {
                        case .AIR:
                            let globalPos = toGlobalPos(chunk: southChunkPos,
                                                        local: southBlockPos)
                        
                            faces.append(BlockFace(direction: .NORTH,
                                                   textureType: sideTexture,
                                                   pos: globalPos))
                        case .SOLID_BLOCK(_, _, _):
                            break
                    }
            }
        }
    }
    return faces
}


func getWestBorderBlockFaces(eastChunkPos: ChunkPos,
                             eastChunk: Chunk,
                             westChunk: Chunk) -> [BlockFace] {
    
    var faces: [BlockFace] = []
    
    let eastLocalX = 0
    let westLocalX = CHUNK_SIDE - 1
    
    let westChunkPos = eastChunkPos.move(.EAST)
    
    for localZ in 0..<CHUNK_SIDE {
        for globalY in 0..<CHUNK_HEIGHT {
            
            let eastBlockPos = BlockPos(X: eastLocalX, Y: globalY, Z: localZ)
            let westBlockPos = BlockPos(X: westLocalX, Y: globalY, Z: localZ)
            
            switch eastChunk[eastBlockPos] {
                case .AIR:
                    switch westChunk[westBlockPos] {
                        case .AIR:
                            break
                        case .SOLID_BLOCK(_, let sideTexture, _):
                            faces.append(BlockFace(direction: .SOUTH,
                                                   textureType: sideTexture,
                                                   pos: toGlobalPos(chunk: westChunkPos,
                                                                    local: westBlockPos)))
                    }
                case .SOLID_BLOCK(_, let sideTexture, _):
                    switch westChunk[westBlockPos] {
                        case .AIR:
                            faces.append(BlockFace(direction: .NORTH,
                                                   textureType: sideTexture,
                                                   pos: toGlobalPos(chunk: eastChunkPos,
                                                                    local: eastBlockPos)))
                        case .SOLID_BLOCK(_, _, _):
                            break
                    }
            }
        }
    }
    return faces
}


func getBlockFaces(chunkPos: ChunkPos, chunk: Chunk) -> [BlockFace] {
    var result: [BlockFace] = []
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in 0..<CHUNK_HEIGHT {
            for localZ in 0..<CHUNK_SIDE {
                
                let localPos = BlockPos(X: localX, Y: globalY, Z: localZ)
                let globalPos = toGlobalPos(chunk: chunkPos, local: localPos)
                
                switch chunk[localPos] {
                    case .AIR: break
                    case .SOLID_BLOCK(let topTexture, let sideTexture, let bottomTexture):
                    
                    if (globalY > 0) {
                        if (chunk[localPos.move(.DOWN)] == .AIR) {
                            result.append(BlockFace(direction: .DOWN,
                                                    textureType: bottomTexture,
                                                    pos: globalPos))
                        }
                    } else {
                        result.append(BlockFace(direction: .DOWN,
                                                textureType: bottomTexture,
                                                pos: globalPos))
                    }
                    
                    if (globalY < CHUNK_HEIGHT - 1) {
                        if (chunk[localPos.move(.UP)] == .AIR) {
                            result.append(BlockFace(direction: .UP,
                                                    textureType: topTexture,
                                                    pos: globalPos))
                        }
                    } else {
                        result.append(BlockFace(direction: .UP,
                                                textureType: topTexture,
                                                pos: globalPos))
                    }
                    
                    if (localX > 0) {
                        if (chunk[localPos.move(.WEST)] == .AIR) {
                            result.append(BlockFace(direction: .WEST,
                                                    textureType: sideTexture,
                                                    pos: globalPos))
                        }
                    }
                    if (localX < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.EAST)] == .AIR) {
                            result.append(BlockFace(direction: .EAST,
                                                    textureType: sideTexture,
                                                    pos: globalPos))
                        }
                    }
                    
                    if (localZ > 0) {
                        if (chunk[localPos.move(.NORTH)] == .AIR) {
                            result.append(BlockFace(direction: .NORTH,
                                                    textureType: sideTexture,
                                                    pos: globalPos))
                        }
                    }
                    if (localZ < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.SOUTH)] == .AIR) {
                            result.append(BlockFace(direction: .SOUTH,
                                                    textureType: sideTexture,
                                                    pos: globalPos))
                        }
                    }
                }
            }
        }
    }
    return result
}
