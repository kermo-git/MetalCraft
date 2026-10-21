import Metal

struct BlockInfo {
    let topTexture: String
    let sideTexture: String
    let bottomTexture: String
    
    init(topTexture: String, sideTexture: String = "", bottomTexture: String = "") {
        self.topTexture = topTexture
        
        if sideTexture == "" {
            self.sideTexture = topTexture
        } else {
            self.sideTexture = sideTexture
        }
        if bottomTexture == "" {
            self.bottomTexture = topTexture
        } else {
            self.bottomTexture = bottomTexture
        }
    }
}

func compileBlocks(_ info: [String:BlockInfo]) -> ([String:UInt16], [String], [Block]) {
    var texture_set: Set<String> = []
    
    for (_, block_info) in info {
        texture_set.insert(block_info.topTexture)
        texture_set.insert(block_info.sideTexture)
        texture_set.insert(block_info.bottomTexture)
    }
    var block_name_to_id: [String:UInt16] = [:]
    let texture_names = Array(texture_set)
    var blocks: [Block] = []
    
    for (block_id, (block_name, block_info)) in info.enumerated() {
        let topTexture = block_info.topTexture
        let sideTexture = block_info.sideTexture
        let bottomTexture = block_info.bottomTexture
        
        let block = Block(topTextureID: UInt16(texture_names.firstIndex(of: topTexture)!),
                          sideTextureID: UInt16(texture_names.firstIndex(of: sideTexture)!),
                          bottomTextureID: UInt16(texture_names.firstIndex(of: bottomTexture)!))
        
        block_name_to_id[block_name] = UInt16(block_id)
        blocks.append(block)
    }
    return (block_name_to_id, texture_names, blocks)
}

struct Block {
    let topTextureID: UInt16
    let sideTextureID: UInt16
    let bottomTextureID: UInt16

    func createVertexShaderData(pos: Int3, orientation: BlockOrientation, directions: Set<Direction>) -> [BlockFace] {
        return directions.map {
            face_direction in
                let tex_direction = reverseOrientDirection(orientation, face_direction)
                let texture_ID = switch tex_direction {
                case .UP:
                    topTextureID
                case .DOWN:
                    bottomTextureID
                default:
                    sideTextureID
                }
                
                return BlockFace(
                    positionXZ: Int2(pos.x, pos.z),
                    positionY: UInt8(pos.y & 255),
                    orientation: (orientation.rawValue << 3) | face_direction.rawValue,
                    textureID: texture_ID
                )
        }
    }
}
