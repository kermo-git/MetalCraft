typealias Faces = [Int3 : Set<Direction>]

extension Faces {
    mutating func append(_ other: Faces) {
        merge(other) { current, other in current.union(other) }
    }
}

func getBlockFaces(chunk: Chunk) -> Faces {
    var result: Faces = [:]
    
    for localX in 0..<chunk.lengthX {
        for globalY in chunk.minY...chunk.maxY {
            for localZ in 0..<chunk.lengthZ {
                
                let localPos = Int3(localX, globalY, localZ)
                
                if !chunk.isEmpty(localPos) {
                    var directions = Set<Direction>()
                    
                    if (globalY > 0 && chunk.isEmpty(localPos.move(.DOWN))) {
                        directions.insert(.DOWN)
                    }
                    if (globalY >= chunk.lengthY - 1 || chunk.isEmpty(localPos.move(.UP))) {
                        directions.insert(.UP)
                    }
                    if (localX > 0 && chunk.isEmpty(localPos.move(.WEST))) {
                        directions.insert(.WEST)
                    }
                    if (localX < chunk.lengthX - 1 && chunk.isEmpty(localPos.move(.EAST))) {
                        directions.insert(.EAST)
                    }
                    if (localZ > 0 && chunk.isEmpty(localPos.move(.NORTH))) {
                        directions.insert(.NORTH)
                    }
                    if (localZ < chunk.lengthZ - 1 && chunk.isEmpty(localPos.move(.SOUTH))) {
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
    let southWallZ = northChunk.lengthZ - 1
    
    for localX in 0..<southChunk.lengthX {
        for globalY in minY...maxY {
            let southChunkBlockPos = Int3(localX, globalY, 0)
            let northChunkBlockPos = Int3(localX, globalY, southWallZ)
            
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
    
    let minY = min(eastChunk.minY, westChunk.minY)
    let maxY = max(eastChunk.maxY, westChunk.maxY)
    let eastWallX = westChunk.lengthX - 1
    
    for localZ in 0..<CHUNK_SIDE {
        for globalY in minY...maxY {
            let eastChunkBlockPos = Int3(0, globalY, localZ)
            let westChunkBlockPos = Int3(eastWallX, globalY, localZ)
            
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
