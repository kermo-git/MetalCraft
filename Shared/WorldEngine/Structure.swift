struct Structure {
    let lengthX: Int32
    let lengthY: Int32
    let lengthZ: Int32
    let anchorBlock: Int3
    
    private var blockID: [UInt16]
    private var rotation: [BlockRotation]
    
    init(blocks: [[[UInt16]]], anchorBlock: Int3, rotation: [[[BlockRotation]]] = []) {
        self.lengthX = Int32(blocks[0][0].count)
        self.lengthY = Int32(blocks.count)
        self.lengthZ = Int32(blocks[0].count)
        self.anchorBlock = anchorBlock
        
        let n_blocks = lengthX*lengthY*lengthZ
        self.blockID = Array(repeating: AIR_ID, count: Int(n_blocks))
        self.rotation = Array(repeating: .NONE, count: Int(n_blocks))
        
        for (y, layer) in blocks.enumerated() {
            for (z, west_east_row) in layer.enumerated() {
                for (x, block) in west_east_row.enumerated() {
                    let pos = Int3(Int32(x), Int32(y), Int32(z))
                    setBlockID(pos, block)
                }
            }
        }
        if rotation.count > 0 {
            for (y, layer) in rotation.enumerated() {
                for (z, west_east_row) in layer.enumerated() {
                    for (x, orientation) in west_east_row.enumerated() {
                        let pos = Int3(Int32(x), Int32(y), Int32(z))
                        setRotation(pos, orientation)
                    }
                }
            }
        }
    }
    
    private func getIndex(_ pos: Int3) -> Int {
        return Int((pos.y * lengthZ + pos.z) * lengthX + pos.x)
    }
    
    func get(_ pos: Int3) -> (UInt16, BlockRotation) {
        let index = getIndex(pos)
        return (blockID[index], rotation[index])
    }
    
    mutating func set(_ pos: Int3, _ blockID: UInt16,
                      _ orientation: BlockRotation = .NONE) {
        let index = getIndex(pos)
        self.blockID[index] = blockID
        self.rotation[index] = orientation
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
    
    func getOrientation(_ pos: Int3) -> BlockRotation {
        rotation[getIndex(pos)]
    }
    
    mutating func setRotation(_ pos: Int3, _ rotation: BlockRotation) {
        self.rotation[getIndex(pos)] = rotation
    }
}
