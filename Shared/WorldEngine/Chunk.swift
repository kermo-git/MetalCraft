let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256
let AIR_ID = -1

struct Chunk {
    let lengthX: Int
    let lengthY: Int
    let lengthZ: Int
    
    private var blockID: [Int]
    private var orientation: [BlockOrientation]
    
    private(set) var minY: Int
    private(set) var maxY: Int
    
    init(lengthX: Int = CHUNK_SIDE,
         lengthY: Int = CHUNK_HEIGHT,
         lengthZ: Int = CHUNK_SIDE) {
        
        self.lengthX = lengthX
        self.lengthY = lengthY
        self.lengthZ = lengthZ
        let numBlocks = lengthX * lengthZ * lengthY
        
        blockID = Array(repeating: AIR_ID, count: numBlocks)
        orientation = Array(repeating: .NONE, count: numBlocks)
        
        self.minY = lengthY - 1
        self.maxY = 0
    }
    
    private func getIndex(_ pos: Int3) -> Int {
        return lengthX * (pos.x * lengthY + pos.y) + pos.z
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
        minY = min(minY, pos.y)
        maxY = max(maxY, pos.y)
    }
    
    func isEmpty(_ pos: Int3) -> Bool {
        blockID[getIndex(pos)] == AIR_ID
    }
    
    func getBlockID(_ pos: Int3) -> Int {
        blockID[getIndex(pos)]
    }
    
    mutating func setBlockID(_ pos: Int3, _ blockID: Int) {
        self.blockID[getIndex(pos)] = blockID
        minY = min(minY, pos.y)
        maxY = max(maxY, pos.y)
    }
    
    func getOrientation(_ pos: Int3) -> BlockOrientation {
        orientation[getIndex(pos)]
    }
    
    mutating func setOrientation(_ pos: Int3, _ orientation: BlockOrientation) {
        self.orientation[getIndex(pos)] = orientation
    }
}
