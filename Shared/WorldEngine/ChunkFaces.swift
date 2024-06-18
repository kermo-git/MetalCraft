typealias Faces = [BlockPos : Set<Direction>]

extension Faces {
    mutating func append(_ other: Faces) {
        merge(other) { current, other in current.union(other) }
    }
}

func getBlockFaces(chunk: Chunk) -> Faces {
    var result: Faces = [:]
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in chunk.minY...chunk.maxY {
            for localZ in 0..<CHUNK_SIDE {
                
                let localPos = BlockPos(X: localX, Y: globalY, Z: localZ)
                let blockID = chunk[localPos]
                
                if blockID != AIR_ID {
                    var directions = Set<Direction>()
                    
                    if (globalY > 0 && chunk[localPos.move(.DOWN)] == AIR_ID) {
                        directions.insert(.DOWN)
                    }
                    if (globalY >= CHUNK_HEIGHT - 1 || chunk[localPos.move(.UP)] == AIR_ID) {
                        directions.insert(.UP)
                    }
                    if (localX > 0 && chunk[localPos.move(.WEST)] == AIR_ID) {
                        directions.insert(.WEST)
                    }
                    if (localX < CHUNK_SIDE - 1 && chunk[localPos.move(.EAST)] == AIR_ID) {
                        directions.insert(.EAST)
                    }
                    if (localZ > 0 && chunk[localPos.move(.NORTH)] == AIR_ID) {
                        directions.insert(.NORTH)
                    }
                    if (localZ < CHUNK_SIDE - 1 && chunk[localPos.move(.SOUTH)] == AIR_ID) {
                        directions.insert(.SOUTH)
                    }
                    if !directions.isEmpty {
                        result[localPos] = directions
                    }
                }
            }
        }
    }
    return result
}

func getNorthBorderBlockFaces(southChunk: Chunk, northChunk: Chunk) -> (Faces, Faces) {
    var southChunkFaces: Faces = [:]
    var northChunkFaces: Faces = [:]
    
    let minY = min(southChunk.minY, northChunk.minY)
    let maxY = max(southChunk.maxY, northChunk.maxY)
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in minY...maxY {
            let southChunkBlockPos = BlockPos(X: localX, Y: globalY, Z: 0)
            let northChunkBlockPos = BlockPos(X: localX, Y: globalY, Z: CHUNK_SIDE - 1)
            
            let southChunkBlockID = southChunk[southChunkBlockPos]
            let northChunkBlockID = northChunk[northChunkBlockPos]
            
            if southChunkBlockID == AIR_ID && northChunkBlockID != AIR_ID {
                northChunkFaces[northChunkBlockPos] = [.SOUTH]
            } 
            else if southChunkBlockID != AIR_ID && northChunkBlockID == AIR_ID {
                southChunkFaces[southChunkBlockPos] = [.NORTH]
            }
        }
    }
    return (southChunkFaces, northChunkFaces)
}


func getWestBorderBlockFaces(eastChunk: Chunk, westChunk: Chunk) -> (Faces, Faces) {
    var eastChunkFaces: Faces = [:]
    var westChunkFaces: Faces = [:]
    
    let minY = min(eastChunk.minY, westChunk.minY)
    let maxY = max(eastChunk.maxY, westChunk.maxY)
    
    for localZ in 0..<CHUNK_SIDE {
        for globalY in minY...maxY {
            let eastChunkBlockPos = BlockPos(X: 0, Y: globalY, Z: localZ)
            let westChunkBlockPos = BlockPos(X: CHUNK_SIDE - 1, Y: globalY, Z: localZ)
            
            let eastChunkBlockID = eastChunk[eastChunkBlockPos]
            let westChunkBlockID = westChunk[westChunkBlockPos]
            
            if eastChunkBlockID == AIR_ID && westChunkBlockID != AIR_ID{
                westChunkFaces[westChunkBlockPos] = [.EAST]
            }
            else if eastChunkBlockID != AIR_ID && westChunkBlockID == AIR_ID {
                eastChunkFaces[eastChunkBlockPos] = [.WEST]
            }
        }
    }
    return (eastChunkFaces, westChunkFaces)
}
