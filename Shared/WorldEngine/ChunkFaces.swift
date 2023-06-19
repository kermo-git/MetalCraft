struct FacePos: Hashable {
    var blockPos: BlockPos
    var direction: Direction
}

typealias Faces = [FacePos : Block]

extension Faces {
    subscript(_ pos: BlockPos, _ dir: Direction) -> Block? {
        get {
            return self[FacePos(blockPos: pos, direction: dir)]
        }
        set {
            self[FacePos(blockPos: pos, direction: dir)] = newValue
        }
    }
    
    mutating func append(_ other: Faces) {
        self.merge(other) { t1, t2 in t1 }
    }
}

func getBlockFaces(chunk: Chunk) -> Faces {
    var result = Faces()
    
    for localX in 0..<CHUNK_SIDE {
        for globalY in 0..<CHUNK_HEIGHT {
            for localZ in 0..<CHUNK_SIDE {
                
                let localPos = BlockPos(X: localX, Y: globalY, Z: localZ)
                let block = chunk[localPos]
                
                switch block {
                    case .AIR: break
                    default:
                    
                    if (globalY > 0) {
                        if (chunk[localPos.move(.DOWN)] == .AIR) {
                            result[localPos, .DOWN] = block
                        }
                    }
                    
                    if (globalY < CHUNK_HEIGHT - 1) {
                        if (chunk[localPos.move(.UP)] == .AIR) {
                            result[localPos, .UP] = block
                        }
                    } else {
                        result[localPos, .UP] = block
                    }
                    
                    if (localX > 0) {
                        if (chunk[localPos.move(.WEST)] == .AIR) {
                            result[localPos, .WEST] = block
                        }
                    }
                    if (localX < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.EAST)] == .AIR) {
                            result[localPos, .EAST] = block
                        }
                    }
                    
                    if (localZ > 0) {
                        if (chunk[localPos.move(.NORTH)] == .AIR) {
                            result[localPos, .NORTH] = block
                        }
                    }
                    if (localZ < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.SOUTH)] == .AIR) {
                            result[localPos, .SOUTH] = block
                        }
                    }
                }
            }
        }
    }
    return result
}

func getNorthBorderBlockFaces(southChunk: Chunk,
                              northChunk: Chunk) -> (Faces, Faces) {
   
   var southChunkFaces = Faces()
   var northChunkFaces = Faces()
   
   for localX in 0..<CHUNK_SIDE {
       for globalY in 0..<CHUNK_HEIGHT {
           
           let northWallPos = BlockPos(X: localX, Y: globalY, Z: 0)
           let southWallPos = BlockPos(X: localX, Y: globalY, Z: CHUNK_SIDE - 1)
           
           let southChunkBlock = southChunk[northWallPos]
           let northChunkBlock = northChunk[southWallPos]
           
           switch southChunkBlock {
               case .AIR:
                   switch northChunkBlock {
                       case .AIR:
                           break
                       default:
                           northChunkFaces[southWallPos, .SOUTH] = northChunkBlock
                   }
               default:
                   switch northChunkBlock {
                       case .AIR:
                           southChunkFaces[northWallPos, .NORTH] = southChunkBlock
                       default:
                           break
                   }
           }
       }
   }
   return (southChunkFaces, northChunkFaces)
}


func getWestBorderBlockFaces(eastChunk: Chunk,
                             westChunk: Chunk) -> (Faces, Faces) {
   
   var eastChunkFaces = Faces()
   var westChunkFaces = Faces()
   
   for localZ in 0..<CHUNK_SIDE {
       for globalY in 0..<CHUNK_HEIGHT {
           
           let westWallPos = BlockPos(X: 0, Y: globalY, Z: localZ)
           let eastWallPos = BlockPos(X: CHUNK_SIDE - 1, Y: globalY, Z: localZ)
           
           let eastChunkBlock = eastChunk[westWallPos]
           let westChunkBlock = westChunk[eastWallPos]
           
           switch eastChunkBlock {
               case .AIR:
                   switch westChunkBlock {
                       case .AIR:
                           break
                       default:
                           westChunkFaces[eastWallPos, .EAST] = westChunkBlock
                   }
               default:
                   switch westChunkBlock {
                       case .AIR:
                           eastChunkFaces[westWallPos, .WEST] = eastChunkBlock
                       default:
                           break
                   }
           }
       }
   }
   return (eastChunkFaces, westChunkFaces)
}
