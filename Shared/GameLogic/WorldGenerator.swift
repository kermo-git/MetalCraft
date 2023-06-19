
let grass: Block = .SOLID_BLOCK(topTexture: .GRASS,
                                sideTexture: .DIRT_GRASS,
                                bottomTexture: .DIRT)

let flowers: Block = .SOLID_BLOCK(topTexture: .WHITE_FLOWERS,
                                  sideTexture: .DIRT_GRASS,
                                  bottomTexture: .DIRT)

let dirt: Block = .SOLID_BLOCK(topTexture: .DIRT,
                               sideTexture: .DIRT,
                               bottomTexture: .DIRT)

let plains = WorldNoise(
    generator: SimplexNoise(),
    unitSquareBlocks: 50,
    minTerrainHeight: 10,
    heightRange: 10
)
let mountains = WorldNoise(
    generator: FractalNoise(
        octaves: 4, persistence: 0.4
    ),
    unitSquareBlocks: 100,
    minTerrainHeight: 30,
    heightRange: 40
)
let terrainType = WorldNoise(
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

func generateChunk(pos: ChunkPos) -> Chunk {
    var chunk = Chunk()
    
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
                chunk[BlockPos(X: i, Y: k, Z: j)] = dirt
            }
            
            chunk[BlockPos(X: i, Y: terrainHeight - 1, Z: j)] =
                Float.random(in: 0...1) > 0.7 ? flowers : grass
        }
    }
    
    return chunk
}
