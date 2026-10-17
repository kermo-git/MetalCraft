let N_CHUNK_LAYER_BLOCKS = CHUNK_SIDE * CHUNK_SIDE
let N_CHUNK_BLOCKS = CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT

let AIR_ID: UInt16 = 0xFFFF

private func getBlockArrayIndex(_ pos: Int3) -> Int {
    return Int(CHUNK_SIDE * (pos.y * CHUNK_SIDE + pos.z) + pos.x)
}

struct Chunk {
    private var blockID: [UInt16]
    private var orientation: [BlockOrientation]
    private(set) var numLayerAirBlocks: [UInt16]
    
    private(set) var minRenderY: Int32 = 0
    private(set) var maxRenderY: Int32 = CHUNK_HEIGHT-1
    private(set) var minBlockY: Int32 = 0
    private(set) var maxBlockY: Int32 = CHUNK_HEIGHT-1
    
    init() {
        numLayerAirBlocks = Array(repeating: UInt16(N_CHUNK_LAYER_BLOCKS), count: Int(CHUNK_HEIGHT))
        blockID = Array(repeating: AIR_ID, count: Int(N_CHUNK_BLOCKS))
        orientation = Array(repeating: .NONE, count: Int(N_CHUNK_BLOCKS))
    }
    
    func get(_ pos: Int3) -> (UInt16, BlockOrientation) {
        let index = getBlockArrayIndex(pos)
        return (blockID[index], orientation[index])
    }
    
    mutating func set(_ pos: Int3, _ blockID: UInt16,
             _ orientation: BlockOrientation = .NONE) {
        let index = getBlockArrayIndex(pos)
        self.blockID[index] = blockID
        self.orientation[index] = orientation
        
        if blockID != AIR_ID {
            numLayerAirBlocks[Int(pos.y)] -= 1
        } else {
            numLayerAirBlocks[Int(pos.y)] += 1
        }
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getBlockArrayIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> UInt16 {
        blockID[getBlockArrayIndex(pos)]
    }
    
    mutating func setBlockID(_ pos: Int3, _ blockID: UInt16) {
        self.blockID[getBlockArrayIndex(pos)] = blockID
        if blockID != AIR_ID {
            numLayerAirBlocks[Int(pos.y)] -= 1
        } else {
            numLayerAirBlocks[Int(pos.y)] += 1
        }
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getBlockArrayIndex(pos)]
    }
    
    mutating func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getBlockArrayIndex(pos)] = orientation
    }
    
    // Determine the Y-coordinate levels that might be visible
    // These blog posts could also be helpful:
    // https://tomcc.github.io/2014/08/31/visibility-1.html
    // https://tomcc.github.io/2014/08/31/visibility-2.html
    mutating func determineYBoundaries() {
        var n_air = numLayerAirBlocks[0]
        var prev_empty = n_air == N_CHUNK_LAYER_BLOCKS
        var prev_full = n_air == 0
        var prev_half_full = !prev_empty && !prev_full
        minBlockY = if !prev_empty {0} else {-1}
        
        for y in 1..<CHUNK_HEIGHT {
            n_air = numLayerAirBlocks[Int(y)]
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
        n_air = numLayerAirBlocks[Int(CHUNK_HEIGHT-1)]
        prev_empty = n_air == N_CHUNK_LAYER_BLOCKS
        prev_full = n_air == 0
        prev_half_full = !prev_empty && !prev_full
        maxBlockY = if !prev_empty {CHUNK_HEIGHT-1} else {-1}
        
        for y in stride(from: CHUNK_HEIGHT-2, through: minRenderY, by: -1) {
            n_air = numLayerAirBlocks[Int(y)]
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
    
    mutating func placeStructure(
        chunkPos: Int2, anchorBlock: Int3, structure: Structure,
        layerIndexes: [Int32], blockID: [UInt16]
    ) {
        let chunk_NW_x = chunkPos.x * CHUNK_SIDE
        let chunk_NW_z = chunkPos.y * CHUNK_SIDE
        
        let chunk_SE_x = chunk_NW_x + CHUNK_SIDE - 1
        let chunk_SE_z = chunk_NW_z + CHUNK_SIDE - 1
        
        let struct_NW_x = anchorBlock.x - structure.anchorBlock.x
        let struct_NW_z = anchorBlock.z - structure.anchorBlock.z
        
        let struct_SE_x = struct_NW_x + structure.lengthX - 1
        let struct_SE_z = struct_NW_z + structure.lengthZ - 1
        
        let west_x = max(struct_NW_x, chunk_NW_x)
        let east_x = min(struct_SE_x, chunk_SE_x)
        
        let north_z = max(struct_NW_z, chunk_NW_z)
        let south_z = min(struct_SE_z, chunk_SE_z)
        
        if west_x <= east_x && north_z <= south_z {
            
            var chunk_y = anchorBlock.y
            
            for struct_y in layerIndexes {
                for x in west_x...east_x {
                    let chunk_x = x - chunk_NW_x
                    let struct_x = x - struct_NW_x
                    
                    for z in north_z...south_z {
                        let chunk_z = z - chunk_NW_z
                        let struct_z = z - struct_NW_z
                        
                        let chunk_block_pos = Int3(chunk_x, chunk_y, chunk_z)
                        let struct_block_pos = Int3(struct_x, struct_y, struct_z)
                        
                        if !structure.isEmpty(struct_block_pos) {
                            let (local_blockID, orientation) = structure.get(struct_block_pos)
                            self.set(chunk_block_pos, blockID[Int(local_blockID)], orientation)
                        }
                    }
                }
                chunk_y += 1
            }
        }
    }
}
