let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256

struct Chunk {
    private var data: [Block] = Array(
        repeating: .AIR,
        count: CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT
    )
    private func getIndex(_ pos: BlockPos) -> Int {
        return CHUNK_SIDE * (pos.X * CHUNK_HEIGHT + pos.Y) + pos.Z
    }
    private(set) var minY = 0
    private(set) var maxY = 0
    
    subscript(_ pos: BlockPos) -> Block {
        get {
            return data[getIndex(pos)]
        }
        set(block) {
            minY = min(minY, pos.Y)
            maxY = max(maxY, pos.Y)
            data[getIndex(pos)] = block
        }
    }
}
