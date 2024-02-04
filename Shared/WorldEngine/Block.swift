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

    func getVertices(pos: BlockPos, directions: Set<Direction>) -> [Vertex] {
        let X = Float(pos.X)
        let Y = Float(pos.Y)
        let Z = Float(pos.Z)
        
        var result: [Vertex] = []
        
        for direction in directions {
            switch direction {
                case .DOWN:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(0, 0), textureID: bottomTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(1, 0), textureID: bottomTextureID),
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: bottomTextureID),
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: bottomTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(1, 0), textureID: bottomTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), textureID: bottomTextureID)
                    ])
                case .UP:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(0, 0), textureID: topTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 1), textureID: topTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 1), textureID: topTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(0, 0), textureID: topTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(1, 0), textureID: topTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 1), textureID: topTextureID)
                    ])
                case .WEST:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: sideTextureID)
                    ])
                case .EAST:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), textureID: sideTextureID)
                    ])
                case .NORTH:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), textureID: sideTextureID)
                    ])
                case .SOUTH:
                    result.append(contentsOf: [
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), textureID: sideTextureID),
                        Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 0), textureID: sideTextureID),
                        Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), textureID: sideTextureID)
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
