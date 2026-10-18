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

    func getVertices(pos: Int3, orientation: BlockOrientation, directions: Set<Direction>) -> [Vertex] {
        let offset = Float3(pos) + 0.5
        func transform(_ vec: Float3) -> Float3 {
            return orientVector(vec, orientation) + offset
        }
        let EDN = transform(Float3( 0.5, -0.5, -0.5))
        let WDN = transform(Float3(-0.5, -0.5, -0.5))
        let EDS = transform(Float3( 0.5, -0.5,  0.5))
        let WDS = transform(Float3(-0.5, -0.5,  0.5))
        
        let EUN = transform(Float3( 0.5,  0.5, -0.5))
        let WUN = transform(Float3(-0.5,  0.5, -0.5))
        let EUS = transform(Float3( 0.5,  0.5,  0.5))
        let WUS = transform(Float3(-0.5,  0.5,  0.5))
        
        var result: [Vertex] = []
        
        let texTopLeft = Half2(0, 0)
        let texTopRight = Half2(1, 0)
        let texBottomLeft = Half2(0, 1)
        let texBottomRight = Half2(1, 1)
        
        for direction in reverseOrientDirections(orientation, directions) {
            switch direction {
                case .DOWN:
                    let normal = Half3(orientVector(Float3(0, -1, 0), orientation))
                
                    result.append(contentsOf: [
                        Vertex(position: EDN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: bottomTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: bottomTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: bottomTextureID),
                    ])
                case .UP:
                    let normal = Half3(orientVector(Float3(0, 1, 0), orientation))
                
                    result.append(contentsOf: [
                        Vertex(position: EUS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: topTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: topTextureID),
                        
                        Vertex(position: EUN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: topTextureID),
                        
                        Vertex(position: WUS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: topTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: topTextureID),
                        
                        Vertex(position: EUS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: topTextureID),
                    ])
                case .WEST:
                    let normal = orientVector(Half3(-1, 0, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: WUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUS, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: sideTextureID),
                    ])
                case .EAST:
                    let normal = orientVector(Half3(1, 0, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: EUS, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDN, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: EUN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: sideTextureID)
                    ])
                case .NORTH:
                    let normal = orientVector(Half3(0, 0, -1), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDN, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: EUN, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID)
                    ])
                case .SOUTH:
                    let normal = orientVector(Half3(0, 0, 1), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: WUS, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: EUS, normal: normal,
                               textureCoords: texTopLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: texBottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: texBottomRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUS, normal: normal,
                               textureCoords: texTopRight,
                               textureID: sideTextureID)
                    ])
            }
        }
        
        return result
    }
}
