class ExampleWorld: WorldGenerator {
    let plains = TerrainNoise(
        generator: SimplexNoise(),
        unitSquareBlocks: 50,
        minTerrainHeight: 60,
        heightRange: 10
    )
    let dirtLayerHeight = 5
    let textureNames: [String]
    let blocks: [Block]
    
    init() {
        let textureNames = [
            "dirt",
            "dirt_grass",
            "grass",
            "stone"
        ]
        self.textureNames = textureNames
        
        func texID(_ textureName: String) -> Int {
            return textureNames.firstIndex(of: textureName) ?? 0
        }
        
        blocks = [
            Block(topTextureID: texID("dirt"),
                  sideTextureID: texID("dirt"),
                  bottomTextureID: texID("dirt")),
            
            Block(topTextureID: texID("grass"),
                  sideTextureID: texID("dirt_grass"),
                  bottomTextureID: texID("dirt")),
            
            Block(topTextureID: texID("stone"),
                  sideTextureID: texID("stone"),
                  bottomTextureID: texID("stone"))
        ]
    }
    
    let DIRT = 0
    let GRASS = 1
    let STONE = 2

    func generateChunk(_ pos: Int2) -> Chunk {
        var chunk = Chunk()
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = Int3(i, 0, j)
                let globalPos = getGlobalBlockPos(chunkPos: pos, localBlockPos: localPos)
                
                let terrainHeight = plains.terrainHeight(globalPos)
                
                for k in 0..<(terrainHeight - dirtLayerHeight) {
                    chunk.set(Int3(i, k, j), STONE)
                }
                for k in (terrainHeight - dirtLayerHeight)...(terrainHeight - 2) {
                    chunk.set(Int3(i, k, j), DIRT)
                }
                chunk.set(Int3(i, terrainHeight - 1, j), GRASS)
            }
        }
        chunk.determineYBoundaries()
        
        return chunk
    }
}
