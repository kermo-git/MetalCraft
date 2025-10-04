let N_CHUNK_LAYER_BLOCKS = CHUNK_SIDE * CHUNK_SIDE
let N_CHUNK_BLOCKS = CHUNK_SIDE * CHUNK_SIDE * CHUNK_HEIGHT

let AIR_ID = -1

private func getBlockArrayIndex(_ pos: Int3) -> Int {
    return CHUNK_SIDE * (pos.y * CHUNK_SIDE + pos.z) + pos.x
}

class Chunk {
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
        let index = getBlockArrayIndex(pos)
        return (blockID[index], orientation[index])
    }
    
    func set(_ pos: Int3, _ blockID: Int,
             _ orientation: BlockOrientation = .NONE) {
        let index = getBlockArrayIndex(pos)
        self.blockID[index] = blockID
        self.orientation[index] = orientation
        
        if blockID != AIR_ID {
            numLayerAirBlocks[pos.y] -= 1
        } else {
            numLayerAirBlocks[pos.y] += 1
        }
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getBlockArrayIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> Int {
        blockID[getBlockArrayIndex(pos)]
    }
    
    func setBlockID(_ pos: Int3, _ blockID: Int) {
        self.blockID[getBlockArrayIndex(pos)] = blockID
        if blockID != AIR_ID {
            numLayerAirBlocks[pos.y] -= 1
        } else {
            numLayerAirBlocks[pos.y] += 1
        }
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getBlockArrayIndex(pos)]
    }
    
    func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getBlockArrayIndex(pos)] = orientation
    }
    
    func determineYBoundaries() {
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
    
    func placeStructure<T: Hashable>(chunk_pos: Int2, struct_NW_corner: Int3, structure: Structure, variant: StructureVariant<T>) {
        let chunk_NW_corner = getGlobalBlockPos(chunkPos: chunk_pos,
                                                localBlockPos: Int3(0, struct_NW_corner.y, 0))
        
        let chunk_SE_corner = getGlobalBlockPos(chunkPos: chunk_pos,
                                                localBlockPos: Int3(CHUNK_SIDE-1, 0, CHUNK_SIDE-1))
        
        let struct_SE_corner = Int3(x: struct_NW_corner.x + structure.lengthX - 1,
                                    y: struct_NW_corner.y,
                                    z: struct_NW_corner.z + structure.lengthZ - 1)
        
        let west_x = max(struct_NW_corner.x, chunk_NW_corner.x)
        let east_x = min(struct_SE_corner.x, chunk_SE_corner.x)
        
        let north_z = max(struct_NW_corner.z, chunk_NW_corner.z)
        let south_z = min(struct_SE_corner.z, chunk_SE_corner.z)
        
        let bottom_y = struct_NW_corner.y
        
        if west_x <= east_x && north_z <= south_z {
            
            for x in west_x...east_x {
                let chunk_x = x - chunk_NW_corner.x
                let struct_x = x - struct_NW_corner.x
                
                for z in north_z...south_z {
                    let chunk_z = z - chunk_NW_corner.z
                    let struct_z = z - struct_NW_corner.z
                    
                    var chunk_y = bottom_y
                    
                    for (unit_y_start, unit_y_end, repeats) in variant.units {
                        for _ in 1...repeats {
                            for struct_y in unit_y_start...unit_y_end {
                                let chunk_block_pos = Int3(chunk_x, chunk_y, chunk_z)
                                let struct_block_pos = Int3(struct_x, struct_y, struct_z)
                                
                                if !structure.isEmpty(struct_block_pos) {
                                    let (blockID, orientation) = structure.get(struct_block_pos)
                                    self.set(chunk_block_pos, variant.blockID[blockID], orientation)
                                }
                                chunk_y += 1
                            }
                        }
                    }
                }
            }
        }
    }
}
