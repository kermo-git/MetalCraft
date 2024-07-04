class ExampleWorld: WorldGenerator {
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
                  bottomTextureID: texID("dirt"),
                  topTexRotation: .FULL,
                  sideTexRotation: .FULL),
            
            Block(topTextureID: texID("grass"),
                  sideTextureID: texID("dirt_grass"),
                  bottomTextureID: texID("dirt"),
                  topTexRotation: .FULL,
                  sideTexRotation: .HORIZONTAL),
            
            Block(topTextureID: texID("stone"),
                  sideTextureID: texID("stone"),
                  bottomTextureID: texID("stone"),
                  topTexRotation: .FULL,
                  sideTexRotation: .FULL)
        ]
    }
    
    let SAND = 0
    let GRASS = 1
    let STONE = 2

    func generateChunk(_ pos: Int2) -> Chunk {
        var chunk = Chunk()
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = Int3(i, 0, j)
                let globalPos = getGlobalBlockPos(chunkPos: pos, localBlockPos: localPos)
                
                let probability = terrainType.noise(globalPos)
                var terrainHeight = 0
                
                var block = SAND
                var topBlock = GRASS
            
                if (probability < transitionStart) {
                    terrainHeight = mountains.terrainHeight(globalPos)
                } else if (probability < transitionEnd) {
                    let mountainsHeight = Float(mountains.terrainHeight(globalPos))
                    let plainsHeight = Float(plains.terrainHeight(globalPos))
                    
                    let blendFactor = fade(
                        (probability - transitionStart) / transitionWidth
                    )
                    
                    terrainHeight = Int(
                        (1 - blendFactor) * mountainsHeight + blendFactor * plainsHeight
                    )
                    block = STONE
                    topBlock = STONE
                } else {
                    terrainHeight = plains.terrainHeight(globalPos)
                }
                
                for k in 0..<(terrainHeight - 1) {
                    chunk.set(Int3(i, k, j), block)
                }
                chunk.set(Int3(i, terrainHeight - 1, j), topBlock)
            }
        }
        
        return chunk
    }
}

let plains = TerrainNoise(
    generator: SimplexNoise(),
    unitSquareBlocks: 50,
    minTerrainHeight: 10,
    heightRange: 10
)
let mountains = TerrainNoise(
    generator: FractalNoise(
        octaves: 4, persistence: 0.4
    ),
    unitSquareBlocks: 100,
    minTerrainHeight: 30,
    heightRange: 40
)
let terrainType = TerrainNoise(
    generator: SimplexNoise(),
    unitSquareBlocks: 200,
    minTerrainHeight: 10,
    heightRange: 10
)
let mountainsProbability: Float = 0.7
let transitionWidth: Float = 0.1
let transitionStart = mountainsProbability - transitionWidth / 2
let transitionEnd = mountainsProbability + transitionWidth / 2

func fade(_ t: Float) -> Float {
    t * t * t * (t * (t * 6 - 15) + 10)
}
