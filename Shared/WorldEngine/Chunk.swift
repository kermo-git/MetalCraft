let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256
let AIR_ID = -1

struct OrientedBlock {
    let blockID: Int
    let orientation: BlockOrientation
}

struct Chunk {
    let pos: Int2
    
    init(pos: Int2) {
        self.pos = pos
    }
    
    private var data: [OrientedBlock] = Array(
        repeating: OrientedBlock(blockID: AIR_ID, 
                                 orientation: .NONE),
        count: CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT
    )
    private func getIndex(_ pos: Int3) -> Int {
        return CHUNK_SIDE * (pos.x * CHUNK_HEIGHT + pos.y) + pos.z
    }
    private(set) var minY = CHUNK_HEIGHT - 1
    private(set) var maxY = 0
    
    subscript(_ pos: Int3) -> OrientedBlock {
        get {
            return data[getIndex(pos)]
        }
        set(block) {
            minY = min(minY, pos.y)
            maxY = max(maxY, pos.y)
            data[getIndex(pos)] = block
        }
    }
}
