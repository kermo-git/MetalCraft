import Metal

struct BlockDescriptor {
    let topTexture: String
    let sideTexture: String
    let bottomTexture: String
}

struct BlockShaderInfo {
    let topTextureID: Int
    let sideTextureID: Int
    let bottomTextureID: Int

    func getVertices(pos: BlockPos, orientation: Orientation, directions: Set<Direction>) -> [Vertex] {
        let offset = Float3(
            Float(pos.X) + 0.5,
            Float(pos.Y) + 0.5,
            Float(pos.Z) + 0.5
        )
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
        
        for direction in reverseOrientDirections(orientation, directions) {
            switch direction {
                case .DOWN:
                    result.append(contentsOf: [
                        Vertex(position: EDN, textureCoords: Float2(1, 0), textureID: bottomTextureID),
                        Vertex(position: WDN, textureCoords: Float2(0, 0), textureID: bottomTextureID),
                        Vertex(position: EDS, textureCoords: Float2(1, 1), textureID: bottomTextureID),
                        Vertex(position: EDS, textureCoords: Float2(1, 1), textureID: bottomTextureID),
                        Vertex(position: WDS, textureCoords: Float2(0, 1), textureID: bottomTextureID),
                        Vertex(position: WDN, textureCoords: Float2(0, 0), textureID: bottomTextureID)
                    ])
                case .UP:
                    result.append(contentsOf: [
                        Vertex(position: EUN, textureCoords: Float2(0, 0), textureID: topTextureID),
                        Vertex(position: WUN, textureCoords: Float2(1, 0), textureID: topTextureID),
                        Vertex(position: EUS, textureCoords: Float2(0, 1), textureID: topTextureID),
                        Vertex(position: EUS, textureCoords: Float2(0, 1), textureID: topTextureID),
                        Vertex(position: WUS, textureCoords: Float2(1, 1), textureID: topTextureID),
                        Vertex(position: WUN, textureCoords: Float2(1, 0), textureID: topTextureID)
                    ])
                case .WEST:
                    result.append(contentsOf: [
                        Vertex(position: WUN, textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: WUS, textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: WDS, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: WDN, textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: WDS, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: WUN, textureCoords: Float2(1, 0), textureID: sideTextureID)
                    ])
                case .EAST:
                    result.append(contentsOf: [
                        Vertex(position: EUN, textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: EUS, textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: EDS, textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: EDN, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: EDS, textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: EUN, textureCoords: Float2(0, 0), textureID: sideTextureID)
                    ])
                case .NORTH:
                    result.append(contentsOf: [
                        Vertex(position: EUN, textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: WUN, textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: WDN, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: EDN, textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: WDN, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: EUN, textureCoords: Float2(1, 0), textureID: sideTextureID)
                    ])
                case .SOUTH:
                    result.append(contentsOf: [
                        Vertex(position: EUS, textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: WUS, textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: EDS, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: EDS, textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: WDS, textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: WUS, textureCoords: Float2(1, 0), textureID: sideTextureID)
                    ])
            }
        }
        
        return result
    }
}

func compileBlockCollection(_ blocksDescriptors: [BlockDescriptor]) -> ([BlockShaderInfo], MTLTexture) {
    var textureNameSet: Set<String> = []
    
    for block in blocksDescriptors {
        textureNameSet.insert(block.topTexture)
        textureNameSet.insert(block.sideTexture)
        textureNameSet.insert(block.bottomTexture)
    }
    let textureNameList = Array(textureNameSet)
    
    let textures = Engine.loadTextureArray(fileNames: textureNameList,
                                           imageWidth: 16,
                                           imageHeight: 16)
    
    var blockInfo: [BlockShaderInfo] = []
    
    for block in blocksDescriptors {
        blockInfo.append(
            BlockShaderInfo(topTextureID:
                                textureNameList.firstIndex(of: block.topTexture) ?? 0,
                            sideTextureID:
                                textureNameList.firstIndex(of: block.sideTexture) ?? 0,
                            bottomTextureID:
                                textureNameList.firstIndex(of: block.bottomTexture) ?? 0)
        )
    }
    return (blockInfo, textures)
}
