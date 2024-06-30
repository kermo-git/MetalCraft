class ExampleWorld: WorldGenerator {
    let blocks = [
        Block(topTexture: "dirt",
              sideTexture: "dirt",
              bottomTexture: "dirt",
              topTexRotation: .FULL,
              sideTexRotation: .FULL),
        
        Block(topTexture: "grass",
              sideTexture: "dirt_grass",
              bottomTexture: "dirt",
              topTexRotation: .FULL,
              sideTexRotation: .HORIZONTAL),
        
        Block(topTexture: "stone",
              sideTexture: "stone",
              bottomTexture: "stone",
              topTexRotation: .FULL,
              sideTexRotation: .FULL)
    ]
    
    let SAND = 0
    let GRASS = 1
    let STONE = 2

    func generate(_ pos: ChunkPos) -> Chunk {
        var chunk = Chunk(pos: pos)
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = BlockPos(X: i, Y: 0, Z: j)
                let globalPos = getGlobalPos(chunk: pos, local: localPos)
                
                let probability = terrainType.noise(globalPos)
                var terrainHeight = 0
                
                var block = OrientedBlock(blockID: SAND,
                                          orientation: .NONE)
                var topBlock = OrientedBlock(blockID: GRASS,
                                             orientation: .NONE)
            
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
                    block = OrientedBlock(blockID: STONE,
                                          orientation: .NONE)
                    topBlock = OrientedBlock(blockID: STONE,
                                             orientation: .NONE)
                } else {
                    terrainHeight = plains.terrainHeight(globalPos)
                }
                
                for k in 0..<(terrainHeight - 1) {
                    chunk[BlockPos(X: i, Y: k, Z: j)] = block
                }
                
                chunk[BlockPos(X: i, Y: terrainHeight - 1, Z: j)] = topBlock
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
