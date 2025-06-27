let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256
let N_CHUNK_LAYER_BLOCKS = CHUNK_SIDE * CHUNK_SIDE
let N_CHUNK_BLOCKS = CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT
let AIR_ID = -1

private func getIndex(_ pos: Int3) -> Int {
    return CHUNK_SIDE * (pos.x * CHUNK_HEIGHT + pos.y) + pos.z
}

struct Chunk {
    private var blockID: [Int]
    private var orientation: [BlockOrientation]
    private(set) var numLayerAirBlocks: [Int]
    
    private(set) var minRenderY: Int = 0
    private(set) var maxRenderY: Int = CHUNK_HEIGHT-1
    private(set) var minBlockY: Int = 0
    private(set) var maxBlockY: Int = CHUNK_HEIGHT-1
    
    init() {
        numLayerAirBlocks = Array(repeating: N_CHUNK_LAYER_BLOCKS, count: CHUNK_HEIGHT)
        blockID = Array(repeating: AIR_ID, count: N_CHUNK_BLOCKS)
        orientation = Array(repeating: .NONE, count: N_CHUNK_BLOCKS)
    }
    
    func get(_ pos: Int3) -> (Int, BlockOrientation) {
        let index = getIndex(pos)
        return (blockID[index], orientation[index])
    }
    
    mutating func set(_ pos: Int3, _ blockID: Int, 
                      _ orientation: BlockOrientation = .NONE) {
        let index = getIndex(pos)
        self.blockID[index] = blockID
        self.orientation[index] = orientation
        
        if blockID != AIR_ID {
            numLayerAirBlocks[pos.y] -= 1
        } else {
            numLayerAirBlocks[pos.y] += 1
        }
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> Int {
        blockID[getIndex(pos)]
    }
    
    mutating func setBlockID(_ pos: Int3, _ blockID: Int) {
        self.blockID[getIndex(pos)] = blockID
        if blockID != AIR_ID {
            numLayerAirBlocks[pos.y] -= 1
        } else {
            numLayerAirBlocks[pos.y] += 1
        }
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getIndex(pos)]
    }
    
    mutating func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getIndex(pos)] = orientation
    }
    
    mutating func determineYBoundaries() {
        var n_air = numLayerAirBlocks[0]
        var prev_empty = n_air == N_CHUNK_LAYER_BLOCKS
        var prev_full = n_air == 0
        var prev_half_full = !prev_empty && !prev_full
        minBlockY = if !prev_empty {0} else {-1}
        
        for y in 1..<CHUNK_HEIGHT {
            n_air = numLayerAirBlocks[y]
            let current_empty = n_air == N_CHUNK_LAYER_BLOCKS
            let current_full = n_air == 0
            let current_half_full = !current_empty && !current_full
            
            if (minBlockY == -1 && !current_empty) {
                minBlockY = y
            }
            if prev_half_full || (!prev_empty && !current_full) {
                minRenderY = y-1
                break
            }
            if current_half_full || (!current_empty && !prev_full) {
                minRenderY = y
                break
            }
            prev_empty = current_empty
            prev_full = current_full
            prev_half_full = current_half_full
        }
        n_air = numLayerAirBlocks[CHUNK_HEIGHT-1]
        prev_empty = n_air == N_CHUNK_LAYER_BLOCKS
        prev_full = n_air == 0
        prev_half_full = !prev_empty && !prev_full
        maxBlockY = if !prev_empty {CHUNK_HEIGHT-1} else {-1}
        
        for y in stride(from: CHUNK_HEIGHT-2, through: minRenderY, by: -1) {
            n_air = numLayerAirBlocks[y]
            let current_empty = n_air == N_CHUNK_LAYER_BLOCKS
            let current_full = n_air == 0
            let current_half_full = !current_empty && !current_full
            
            if (maxBlockY == -1 && !current_empty) {
                maxBlockY = y
            }
            if prev_half_full || (!prev_empty && !current_full) {
                maxRenderY = y+1
                break
            }
            if current_half_full || (!current_empty && !prev_full) {
                maxRenderY = y
                break
            }
            prev_empty = current_empty
            prev_full = current_full
            prev_half_full = current_half_full
        }
    }
}
