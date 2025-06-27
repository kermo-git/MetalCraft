typealias Faces = [Int3 : Set<Direction>]

extension Faces {
    mutating func append(_ other: Faces) {
        merge(other) { current, other in current.union(other) }
    }
}

func getBlockFaces(chunk: Chunk) -> Faces {
    var result: Faces = [:]
    
    for globalY in chunk.minRenderY...chunk.maxRenderY {
        for localX in 0..<CHUNK_SIDE {
            for localZ in 0..<CHUNK_SIDE {
                
                let localPos = Int3(localX, globalY, localZ)
                
                if !chunk.isEmpty(localPos) {
                    var directions = Set<Direction>()
                    
                    if (globalY > 0 && chunk.isEmpty(localPos.move(.DOWN))) {
                        directions.insert(.DOWN)
                    }
                    if (globalY >= CHUNK_HEIGHT - 1 || chunk.isEmpty(localPos.move(.UP))) {
                        directions.insert(.UP)
                    }
                    if (localX > 0 && chunk.isEmpty(localPos.move(.WEST))) {
                        directions.insert(.WEST)
                    }
                    if (localX < CHUNK_SIDE - 1 && chunk.isEmpty(localPos.move(.EAST))) {
                        directions.insert(.EAST)
                    }
                    if (localZ > 0 && chunk.isEmpty(localPos.move(.NORTH))) {
                        directions.insert(.NORTH)
                    }
                    if (localZ < CHUNK_SIDE - 1 && chunk.isEmpty(localPos.move(.SOUTH))) {
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
    
    let minY = min(southChunk.minBlockY, northChunk.minBlockY)
    let maxY = max(southChunk.maxBlockY, northChunk.maxBlockY)
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in minY...maxY {
            let southChunkBlockPos = Int3(localX, globalY, 0)
            let northChunkBlockPos = Int3(localX, globalY, CHUNK_SIDE - 1)
            
            let southEmpty = southChunk.isEmpty(southChunkBlockPos)
            let northEmpty = northChunk.isEmpty(northChunkBlockPos)
            
            if southEmpty && !northEmpty {
                northChunkFaces[northChunkBlockPos] = [.SOUTH]
            } 
            else if !southEmpty && northEmpty {
                southChunkFaces[southChunkBlockPos] = [.NORTH]
            }
        }
    }
    return (southChunkFaces, northChunkFaces)
}


func getWestBorderBlockFaces(eastChunk: Chunk, westChunk: Chunk) -> (Faces, Faces) {
    var eastChunkFaces: Faces = [:]
    var westChunkFaces: Faces = [:]
    
    let minY = min(eastChunk.minBlockY, westChunk.minBlockY)
    let maxY = max(eastChunk.maxBlockY, westChunk.maxBlockY)
    
    for localZ in 0..<CHUNK_SIDE {
        for globalY in minY...maxY {
            let eastChunkBlockPos = Int3(0, globalY, localZ)
            let westChunkBlockPos = Int3(CHUNK_SIDE - 1, globalY, localZ)
            
            let eastEmpty = eastChunk.isEmpty(eastChunkBlockPos)
            let westEmpty = westChunk.isEmpty(westChunkBlockPos)
            
            if eastEmpty && !westEmpty {
                westChunkFaces[westChunkBlockPos] = [.EAST]
            }
            else if !eastEmpty && westEmpty {
                eastChunkFaces[eastChunkBlockPos] = [.WEST]
            }
        }
    }
    return (eastChunkFaces, westChunkFaces)
}
