let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256
let AIR_ID = -1

struct OrientedBlock {
    let blockID: Int
    let orientation: BlockOrientation
}

struct Chunk {
    let pos: ChunkPos
    
    init(pos: ChunkPos) {
        self.pos = pos
    }
    
    private var data: [OrientedBlock] = Array(
        repeating: OrientedBlock(blockID: AIR_ID, 
                                 orientation: .NONE),
        count: CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT
    )
    private func getIndex(_ pos: BlockPos) -> Int {
        return CHUNK_SIDE * (pos.X * CHUNK_HEIGHT + pos.Y) + pos.Z
    }
    private(set) var minY = CHUNK_HEIGHT - 1
    private(set) var maxY = 0
    
    subscript(_ pos: BlockPos) -> OrientedBlock {
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
