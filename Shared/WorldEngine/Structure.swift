struct Structure {
    let lengthX: Int
    let lengthY: Int
    let lengthZ: Int
    let anchorBlock: Int3
    
    private var blockID: [Int]
    private var orientation: [BlockOrientation]
    
    init(blocks: [[[Int]]], anchorBlock: Int3, orientations: [[[BlockOrientation]]] = []) {
        self.lengthX = blocks[0][0].count
        self.lengthY = blocks.count
        self.lengthZ = blocks[0].count
        self.anchorBlock = anchorBlock
        
        let n_blocks = lengthX*lengthY*lengthZ
        self.blockID = Array(repeating: AIR_ID, count: n_blocks)
        self.orientation = Array(repeating: .NONE, count: n_blocks)
        
        for (y, layer) in blocks.enumerated() {
            for (z, west_east_row) in layer.enumerated() {
                for (x, block) in west_east_row.enumerated() {
                    setBlockID(Int3(x, y, z), block)
                }
            }
        }
        if orientation.count > 0 {
            for (y, layer) in orientations.enumerated() {
                for (z, west_east_row) in layer.enumerated() {
                    for (x, orientation) in west_east_row.enumerated() {
                        setOrientation(Int3(x, y, z), orientation)
                    }
                }
            }
        }
    }
    
    private func getIndex(_ pos: Int3) -> Int {
        return (pos.y * lengthZ + pos.z) * lengthX + pos.x
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
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> Int {
        blockID[getIndex(pos)]
    }
    
    mutating func setBlockID(_ pos: Int3, _ blockID: Int) {
        self.blockID[getIndex(pos)] = blockID
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getIndex(pos)]
    }
    
    mutating func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getIndex(pos)] = orientation
    }
}
