import Metal

struct Block {
    let topTextureID: Int
    let sideTextureID: Int
    let bottomTextureID: Int
    
    let topTexRotation: RandomTextureRotation
    let sideTexRotation: RandomTextureRotation

    func getVertices(pos: Int3, orientation: BlockOrientation, directions: Set<Direction>) -> [Vertex] {
        let offset = Float3(
            Float(pos.x) + 0.5,
            Float(pos.y) + 0.5,
            Float(pos.z) + 0.5
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
        let topTexCoords = getTextureCoords(rotation: topTexRotation)
        let sideTexCoords = getTextureCoords(rotation: sideTexRotation)
        
        for direction in reverseOrientDirections(orientation, directions) {
            switch direction {
                case .DOWN:
                    let normal = orientVector(Float3(0, -1, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EDN, normal: normal,
                               textureCoords: topTexCoords.topRight,
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: topTexCoords.topLeft,
                               textureID: bottomTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: topTexCoords.bottomRight,
                                textureID: bottomTextureID),
                        
                        Vertex(position: EDS, normal: normal,
                               textureCoords: topTexCoords.bottomRight,
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: topTexCoords.bottomLeft, 
                               textureID: bottomTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: topTexCoords.topLeft, 
                               textureID: bottomTextureID)
                    ])
                case .UP:
                    let normal = orientVector(Float3(0, 1, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUN, normal: normal,
                               textureCoords: topTexCoords.topLeft, 
                               textureID: topTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: topTexCoords.topRight, 
                               textureID: topTextureID),
                        
                        Vertex(position: EUS, normal: normal,
                               textureCoords: topTexCoords.bottomLeft, 
                               textureID: topTextureID),
                        
                        Vertex(position: EUS, normal: normal,
                               textureCoords: topTexCoords.bottomLeft,
                               textureID: topTextureID),
                        
                        Vertex(position: WUS, normal: normal,
                               textureCoords: topTexCoords.bottomRight,
                               textureID: topTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: topTexCoords.topRight,
                               textureID: topTextureID)
                    ])
                case .WEST:
                    let normal = orientVector(Float3(-1, 0, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: WUN, normal: normal,
                               textureCoords: sideTexCoords.topRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUS, normal: normal,
                               textureCoords: sideTexCoords.topLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDN, normal: normal,
                               textureCoords: sideTexCoords.bottomRight,
                               textureID: sideTextureID),
                        
                        Vertex(position: WDS, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft,
                               textureID: sideTextureID),
                        
                        Vertex(position: WUN, normal: normal,
                               textureCoords: sideTexCoords.topRight,
                               textureID: sideTextureID)
                    ])
                case .EAST:
                    let normal = orientVector(Float3(1, 0, 0), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUN, normal: normal,
                               textureCoords: sideTexCoords.topLeft, textureID: sideTextureID),
                        Vertex(position: EUS, normal: normal,
                               textureCoords: sideTexCoords.topRight, textureID: sideTextureID),
                        Vertex(position: EDS, normal: normal,
                               textureCoords: sideTexCoords.bottomRight, textureID: sideTextureID),
                        Vertex(position: EDN, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft, textureID: sideTextureID),
                        Vertex(position: EDS, normal: normal,
                               textureCoords: sideTexCoords.bottomRight, textureID: sideTextureID),
                        Vertex(position: EUN, normal: normal,
                               textureCoords: sideTexCoords.topLeft, textureID: sideTextureID)
                    ])
                case .NORTH:
                    let normal = orientVector(Float3(0, 0, -1), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUN, normal: normal,
                               textureCoords: sideTexCoords.topRight, textureID: sideTextureID),
                        Vertex(position: WUN, normal: normal,
                               textureCoords: sideTexCoords.topLeft, textureID: sideTextureID),
                        Vertex(position: WDN, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft, textureID: sideTextureID),
                        Vertex(position: EDN, normal: normal,
                               textureCoords: sideTexCoords.bottomRight, textureID: sideTextureID),
                        Vertex(position: WDN, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft, textureID: sideTextureID),
                        Vertex(position: EUN, normal: normal,
                               textureCoords: sideTexCoords.topRight, textureID: sideTextureID)
                    ])
                case .SOUTH:
                    let normal = orientVector(Float3(0, 0, 1), orientation)
                
                    result.append(contentsOf: [
                        Vertex(position: EUS, normal: normal,
                               textureCoords: sideTexCoords.topLeft, textureID: sideTextureID),
                        Vertex(position: WUS, normal: normal,
                               textureCoords: sideTexCoords.topRight, textureID: sideTextureID),
                        Vertex(position: EDS, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft, textureID: sideTextureID),
                        Vertex(position: EDS, normal: normal,
                               textureCoords: sideTexCoords.bottomLeft, textureID: sideTextureID),
                        Vertex(position: WDS, normal: normal,
                               textureCoords: sideTexCoords.bottomRight, textureID: sideTextureID),
                        Vertex(position: WUS, normal: normal,
                               textureCoords: sideTexCoords.topRight, textureID: sideTextureID)
                    ])
            }
        }
        
        return result
    }
}
