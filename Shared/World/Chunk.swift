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
