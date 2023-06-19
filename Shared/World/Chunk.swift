enum Direction: Hashable {
    case UP
    case DOWN
    case WEST
    case EAST
    case SOUTH
    case NORTH
}

enum TextureType: CaseIterable {
    case GRASS
    case WHITE_FLOWERS
    case DIRT_GRASS
    case DIRT
}

enum Block: Equatable {
    case AIR
    case SOLID_BLOCK(topTexture: TextureType,
                     sideTexture: TextureType,
                     bottomTexture: TextureType)
}

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

struct FacePos: Hashable {
    var blockPos: BlockPos
    var direction: Direction
}

typealias Faces = [FacePos : TextureType]

extension Faces {
    subscript(_ pos: BlockPos, _ dir: Direction) -> TextureType? {
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
                
                switch chunk[localPos] {
                    case .AIR: break
                    case .SOLID_BLOCK(let topTexture, let sideTexture, let bottomTexture):
                    
                    if (globalY > 0) {
                        if (chunk[localPos.move(.DOWN)] == .AIR) {
                            result[localPos, .DOWN] = bottomTexture
                        }
                    }
                    
                    if (globalY < CHUNK_HEIGHT - 1) {
                        if (chunk[localPos.move(.UP)] == .AIR) {
                            result[localPos, .UP] = topTexture
                        }
                    } else {
                        result[localPos, .UP] = topTexture
                    }
                    
                    if (localX > 0) {
                        if (chunk[localPos.move(.WEST)] == .AIR) {
                            result[localPos, .WEST] = sideTexture
                        }
                    }
                    if (localX < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.EAST)] == .AIR) {
                            result[localPos, .EAST] = sideTexture
                        }
                    }
                    
                    if (localZ > 0) {
                        if (chunk[localPos.move(.NORTH)] == .AIR) {
                            result[localPos, .NORTH] = sideTexture
                        }
                    }
                    if (localZ < CHUNK_SIDE - 1) {
                        if (chunk[localPos.move(.SOUTH)] == .AIR) {
                            result[localPos, .SOUTH] = sideTexture
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
           
           switch southChunk[northWallPos] {
               case .AIR:
                   switch northChunk[southWallPos] {
                       case .AIR:
                           break
                       case .SOLID_BLOCK(_, let sideTexture, _):
                           northChunkFaces[southWallPos, .SOUTH] = sideTexture
                   }
               case .SOLID_BLOCK(_, let sideTexture, _):
                   switch northChunk[southWallPos] {
                       case .AIR:
                           southChunkFaces[northWallPos, .NORTH] = sideTexture
                       case .SOLID_BLOCK(_, _, _):
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
           
           switch eastChunk[westWallPos] {
               case .AIR:
                   switch westChunk[eastWallPos] {
                       case .AIR:
                           break
                       case .SOLID_BLOCK(_, let sideTexture, _):
                           westChunkFaces[eastWallPos, .EAST] = sideTexture
                   }
               case .SOLID_BLOCK(_, let sideTexture, _):
                   switch westChunk[eastWallPos] {
                       case .AIR:
                           eastChunkFaces[westWallPos, .WEST] = sideTexture
                       case .SOLID_BLOCK(_, _, _):
                           break
                   }
           }
       }
   }
   return (eastChunkFaces, westChunkFaces)
}
