class ExampleWorld: WorldGenerator {
    let blocks = [
        BlockDescriptor(topTexture: "DIRT",
                        sideTexture: "DIRT",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "GRASS",
                        sideTexture: "DIRT_GRASS",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "WHITE_FLOWERS",
                        sideTexture: "DIRT_GRASS",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "YELLOW_FLOWERS",
                        sideTexture: "DIRT_GRASS",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "BLUE_FLOWERS",
                        sideTexture: "DIRT_GRASS",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "RED_FLOWERS",
                        sideTexture: "DIRT_GRASS",
                        bottomTexture: "DIRT"),
        
        BlockDescriptor(topTexture: "TREE_CUT",
                        sideTexture: "TREE_BARK",
                        bottomTexture: "TREE_CUT"),
    ]
    
    let DIRT = 0
    let GRASS = 1
    let WHITE_FLOWERS = 2
    let YELLOW_FLOWERS = 3
    let BLUE_FLOWERS = 4
    let RED_FLOWERS = 5
    let WOOD = 6

    func generate(_ pos: ChunkPos) -> Chunk {
        var chunk = Chunk(pos: pos)
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = BlockPos(X: i, Y: 0, Z: j)
                let globalPos = getGlobalPos(chunk: pos, local: localPos)
                
                let probability = terrainType.noise(globalPos)
                var terrainHeight = 0
            
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
                } else {
                    terrainHeight = plains.terrainHeight(globalPos)
                }
                
                for k in 0..<(terrainHeight - 1) {
                    chunk[BlockPos(X: i, Y: k, Z: j)] = OrientedBlock(blockID: DIRT,
                                                                      orientation: .NONE)
                }
                let grass = OrientedBlock(blockID: GRASS,
                                          orientation: .NONE)
                
                chunk[BlockPos(X: i, Y: terrainHeight - 1, Z: j)] = grass
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

let woodNoise = TerrainNoise(
    generator: FractalNoise(
        octaves: 4, persistence: 0.4
    ),
    unitSquareBlocks: 50,
    minTerrainHeight: 0,
    heightRange: 0
)

func fade(_ t: Float) -> Float {
    t * t * t * (t * (t * 6 - 15) + 10)
}
