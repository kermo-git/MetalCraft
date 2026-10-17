struct Structure {
    let lengthX: Int32
    let lengthY: Int32
    let lengthZ: Int32
    let anchorBlock: Int3
    
    private var blockID: [UInt16]
    private var orientation: [BlockOrientation]
    
    init(blocks: [[[UInt16]]], anchorBlock: Int3, orientations: [[[BlockOrientation]]] = []) {
        self.lengthX = Int32(blocks[0][0].count)
        self.lengthY = Int32(blocks.count)
        self.lengthZ = Int32(blocks[0].count)
        self.anchorBlock = anchorBlock
        
        let n_blocks = lengthX*lengthY*lengthZ
        self.blockID = Array(repeating: AIR_ID, count: Int(n_blocks))
        self.orientation = Array(repeating: .NONE, count: Int(n_blocks))
        
        for (y, layer) in blocks.enumerated() {
            for (z, west_east_row) in layer.enumerated() {
                for (x, block) in west_east_row.enumerated() {
                    let pos = Int3(Int32(x), Int32(y), Int32(z))
                    setBlockID(pos, block)
                }
            }
        }
        if orientation.count > 0 {
            for (y, layer) in orientations.enumerated() {
                for (z, west_east_row) in layer.enumerated() {
                    for (x, orientation) in west_east_row.enumerated() {
                        let pos = Int3(Int32(x), Int32(y), Int32(z))
                        setOrientation(pos, orientation)
                    }
                }
            }
        }
    }
    
    private func getIndex(_ pos: Int3) -> Int {
        return Int((pos.y * lengthZ + pos.z) * lengthX + pos.x)
    }
    
    func get(_ pos: Int3) -> (UInt16, BlockOrientation) {
        let index = getIndex(pos)
        return (blockID[index], orientation[index])
    }
    
    mutating func set(_ pos: Int3, _ blockID: UInt16,
                      _ orientation: BlockOrientation = .NONE) {
        let index = getIndex(pos)
        self.blockID[index] = blockID
        self.orientation[index] = orientation
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> UInt16 {
        blockID[getIndex(pos)]
    }
    
    mutating func setBlockID(_ pos: Int3, _ blockID: UInt16) {
        self.blockID[getIndex(pos)] = blockID
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getIndex(pos)]
    }
    
    mutating func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getIndex(pos)] = orientation
    }
}
