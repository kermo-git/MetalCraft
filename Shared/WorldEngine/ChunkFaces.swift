typealias Faces = [Int3 : Set<Direction>]

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
                
                let localPos = Int3(localX, globalY, localZ)
                let blockID = chunk[localPos].blockID
                
                if blockID != AIR_ID {
                    var directions = Set<Direction>()
                    
                    if (globalY > 0 && chunk[localPos.move(.DOWN)].blockID == AIR_ID) {
                        directions.insert(.DOWN)
                    }
                    if (globalY >= CHUNK_HEIGHT - 1 || chunk[localPos.move(.UP)].blockID == AIR_ID) {
                        directions.insert(.UP)
                    }
                    if (localX > 0 && chunk[localPos.move(.WEST)].blockID == AIR_ID) {
                        directions.insert(.WEST)
                    }
                    if (localX < CHUNK_SIDE - 1 && chunk[localPos.move(.EAST)].blockID == AIR_ID) {
                        directions.insert(.EAST)
                    }
                    if (localZ > 0 && chunk[localPos.move(.NORTH)].blockID == AIR_ID) {
                        directions.insert(.NORTH)
                    }
                    if (localZ < CHUNK_SIDE - 1 && chunk[localPos.move(.SOUTH)].blockID == AIR_ID) {
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
            let southChunkBlockPos = Int3(localX, globalY, 0)
            let northChunkBlockPos = Int3(localX, globalY, CHUNK_SIDE - 1)
            
            let southChunkBlockID = southChunk[southChunkBlockPos].blockID
            let northChunkBlockID = northChunk[northChunkBlockPos].blockID
            
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
            let eastChunkBlockPos = Int3(0, globalY, localZ)
            let westChunkBlockPos = Int3(CHUNK_SIDE - 1, globalY, localZ)
            
            let eastChunkBlockID = eastChunk[eastChunkBlockPos].blockID
            let westChunkBlockID = westChunk[westChunkBlockPos].blockID
            
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
