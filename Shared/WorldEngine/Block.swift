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
    
    func encode3x5bitTriplet(_ x: UInt16, _ y: UInt16, _ z: UInt16) -> UInt16 {
        (x << 10) | (y << 5) | z
    }
    
    func encodeShapeIDTexRotation(
        shapeID: Direction, texRotation: TextureRotation
    ) -> UInt8 {
        (shapeID.rawValue << 2) | texRotation.rawValue
    }

    func createVertexShaderData(pos: Int3, rotation: BlockRotation, directions: Set<Direction>) -> [Quad] {
        return directions.map { face_orientation in
            let (tex_face, tex_rotation) = findRotatedFace(rotation, face_orientation)
            
            let texture_ID = switch tex_face {
            case .UP:
                topTextureID
            case .DOWN:
                bottomTextureID
            default:
                sideTextureID
            }
            
            let quad_pos: UInt16 = switch face_orientation {
            case .UP: encode3x5bitTriplet(0, 16, 0)
            case .DOWN: encode3x5bitTriplet(0, 0, 0)
            case .WEST: encode3x5bitTriplet(0, 0, 0)
            case .EAST: encode3x5bitTriplet(16, 0, 0)
            case .SOUTH: encode3x5bitTriplet(0, 0, 16)
            case .NORTH: encode3x5bitTriplet(0, 0, 0)
            }
                
            return Quad(
                blockPosXZ: Int2(pos.x, pos.z),
                blockPosY: UInt8(pos.y & 255),
                shapeID_texRotation: encodeShapeIDTexRotation(
                    shapeID: face_orientation,
                    texRotation: tex_rotation
                ),
                textureID: texture_ID,
                quadPos: quad_pos,
                quadSize: encode3x5bitTriplet(16, 16, 16)
            )
        }
    }
}
