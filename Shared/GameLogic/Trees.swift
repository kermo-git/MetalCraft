func buildTree() -> Structure {
    let A = AIR_ID
    let W = 0 // Wood
    let L = 1 // Leaves
    
    return Structure(blocks: [
        // Trunk layer
        [[A, A, A, A, A],
         [A, A, A, A, A],
         [A, A, W, A, A],
         [A, A, A, A, A],
         [A, A, A, A, A]],
        
        // Bottom part of canopy
        [[A, A, L, A, A],
         [A, L, L, L, A],
         [L, L, W, L, L],
         [A, L, L, L, A],
         [A, A, L, A, A]],
        
        // Middle part of canopy
        [[A, L, L, L, A],
         [L, L, L, L, L],
         [L, L, W, L, L],
         [L, L, L, L, L],
         [A, L, L, L, A]],
        
        // Top part of canopy
        [[A, A, L, A, A],
         [A, L, L, L, A],
         [L, L, W, L, L],
         [A, L, L, L, A],
         [A, A, L, A, A]],
        [[A, A, A, A, A],
         [A, A, L, A, A],
         [A, L, L, L, A],
         [A, A, L, A, A],
         [A, A, A, A, A]]
    ], anchorBlock: Int3(2, 0, 2))
}

func treeLayerRepeats(_ trunkBlocks: Int, _ canopyBottomBlocks: Int, _ canopyMiddleBlocks: Int) -> [Int] {
    var result = Array(repeating: 0, count: trunkBlocks)
    result.append(contentsOf: Array(repeating: 1, count: canopyBottomBlocks))
    result.append(contentsOf: Array(repeating: 2, count: canopyMiddleBlocks))
    result.append(contentsOf: [3, 4])
    return result
}

func buildSpruceTree() -> Structure {
    let A = AIR_ID
    let W = 0 // Wood
    let L = 1 // Leaves
    let S = 2 // Snow covered leaves
    
    return Structure(blocks: [
        // Trunk layer
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, W, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // Skip this layer for small version
        [[A, A, S, L, S, A, A],
         [A, L, L, L, L, L, A],
         [S, L, L, L, L, L, S],
         [L, L, L, W, L, L, L],
         [S, L, L, L, L, L, S],
         [A, L, L, L, L, L, A],
         [A, A, S, L, S, A, A]],
        
        // Skip this layer for small or short version
        [[A, A, A, L, A, A, A],
         [A, L, L, L, L, L, A],
         [A, L, L, L, L, L, A],
         [L, L, L, W, L, L, L],
         [A, L, L, L, L, L, A],
         [A, L, L, L, L, L, A],
         [A, A, A, L, A, A, A]],
        
        // Skip this layer for small version
        [[A, A, A, S, A, A, A],
         [A, S, L, L, L, S, A],
         [A, L, L, L, L, L, A],
         [S, L, L, W, L, L, S],
         [A, L, L, L, L, L, A],
         [A, S, L, L, L, S, A],
         [A, A, A, S, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, S, L, S, A, A],
         [A, S, L, L, L, S, A],
         [A, L, L, W, L, L, A],
         [A, S, L, L, L, S, A],
         [A, A, S, L, S, A, A],
         [A, A, A, A, A, A, A]],
        
        // Skip this layer for short version
        [[A, A, A, A, A, A, A],
         [A, A, A, L, A, A, A],
         [A, A, L, L, L, A, A],
         [A, L, L, W, L, L, A],
         [A, A, L, L, L, A, A],
         [A, A, A, L, A, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, S, A, A, A],
         [A, A, L, L, L, A, A],
         [A, S, L, W, L, S, A],
         [A, A, L, L, L, A, A],
         [A, A, A, S, A, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, S, L, S, A, A],
         [A, A, L, W, L, A, A],
         [A, A, S, L, S, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // Skip this layer for short version
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, L, A, A, A],
         [A, A, L, W, L, A, A],
         [A, A, A, L, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, S, A, A, A],
         [A, A, S, W, S, A, A],
         [A, A, A, S, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, L, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, S, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    ], anchorBlock: Int3(3, 0, 3))
}

func spruceLayerRepeats(trunkBlocks: Int, isLarge: Bool, isTall: Bool) -> [Int] {
    var result = Array(repeating: 0, count: trunkBlocks)
    
    if isLarge {
        if isTall {
            result.append(contentsOf: [1,2,3])
        } else {
            result.append(contentsOf: [1,3])
        }
    }
    if isTall {
        result.append(contentsOf: 4...11)
    } else {
        result.append(contentsOf: [4, 6, 7, 9, 10, 11])
    }
    
    return result
}

/*
func buildPineTree() -> Structure {
    let A = AIR_ID
    let G = 0 // Trunk with gray bark
    let T = 1 // Trunk with transition from gray to orange
    let O = 2 // Trunk with orange bark
    let L = 3 // Leaves
        
    return Structure(blocks: [
        // 0: GRAY_TRUNK
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, G, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 1: TRANSITION_TRUNK
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, T, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
 
        // 2: ORANGE_TRUNK
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, O, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
        
        // 3: SMALL_CANOPY_RING
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, L, L, L, A, A],
         [A, A, L, O, L, A, A],
         [A, A, L, L, L, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 4: LARGE_CANOPY_RING
        [[A, A, L, L, L, A, A],
         [A, L, L, L, L, L, A],
         [L, L, L, L, L, L, L],
         [L, L, L, O, L, L, L],
         [L, L, L, L, L, L, L],
         [A, L, L, L, L, L, A],
         [A, A, L, L, L, A, A]],
        
        // 5: NORTH_SMALL_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, L, L, A, A, A],
         [A, L, L, L, A, A, A],
         [A, L, L, O, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 6: EAST_SMALL_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, A, L, L, A, A],
         [A, A, A, L, L, L, A],
         [A, A, A, O, L, L, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 7: SOUTH_SMALL_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, O, L, L, A],
         [A, A, A, L, L, L, A],
         [A, A, A, L, L, A, A],
         [A, A, A, A, A, A, A]],
        
        // 8: WEST_SMALL_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, L, L, O, A, A, A],
         [A, L, L, L, A, A, A],
         [A, A, L, L, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 9: NORTH_LARGE_SIDE_BRANCH
        [[A, A, A, L, L, A, A],
         [A, A, L, L, L, L, A],
         [A, A, L, L, L, L, A],
         [A, A, A, O, L, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 10: EAST_LARGE_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, L, L, A],
         [A, A, A, O, L, L, L],
         [A, A, A, L, L, L, L],
         [A, A, A, A, L, L, A],
         [A, A, A, A, A, A, A]],
        
        // 11: SOUTH_LARGE_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, L, O, A, A, A],
         [A, L, L, L, L, A, A],
         [A, L, L, L, L, A, A],
         [A, A, L, L, A, A, A]],
        
        // 12: WEST_LARGE_SIDE_BRANCH
        [[A, A, A, A, A, A, A],
         [A, L, L, A, A, A, A],
         [L, L, L, L, A, A, A],
         [L, L, L, O, A, A, A],
         [A, L, L, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]],
        
        // 13-14: CANOPY_TOP
        [[A, A, A, A, A, A, A],
         [A, A, L, L, L, A, A],
         [A, L, L, L, L, L, A],
         [A, L, L, O, L, L, A],
         [A, L, L, L, L, L, A],
         [A, A, L, L, L, A, A],
         [A, A, A, A, A, A, A]],
        
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, L, L, L, A, A],
         [A, A, L, L, L, A, A],
         [A, A, L, L, L, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    ])
}
*/
