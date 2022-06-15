
let sandGrass: Block = .SOLID_BLOCK(topTexture: .GRASS,
                                    sideTexture: .STONE_GRASS,
                                    bottomTexture: .STONE)

let treeTrunk: Block = .SOLID_BLOCK(topTexture: .TREE_CUT,
                                    sideTexture: .TREE_BARK,
                                    bottomTexture: .TREE_CUT)

class WorldGenerator {
    let generator = SimplexNoise()
    
    let NOISE_UNIT_BLOCKS: Float = 20
    let BASE_HEIGHT: Int = 10
    let NOISE_RANGE: Float = 10
    
    func terrainHeight(pos: BlockPos) -> Int {
        let noiseX = Float(pos.X) / NOISE_UNIT_BLOCKS
        let noiseY = Float(pos.Z) / NOISE_UNIT_BLOCKS
        
        let noiseValue = generator.noise(noiseX, noiseY, 0)
        return BASE_HEIGHT + Int(noiseValue * NOISE_RANGE)
    }
    
    func generateChunk(pos: ChunkPos) -> Chunk {
        var chunk = Chunk()
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = BlockPos(X: i, Y: 0, Z: j)
                let globalPos = toGlobalPos(chunk: pos, local: localPos)
                let terrainHeight = terrainHeight(pos: globalPos)
                
                for k in 0..<terrainHeight {
                    chunk[BlockPos(X: i, Y: k, Z: j)] = sandGrass
                }
                if (i * j == 12) {
                    for k in terrainHeight..<(terrainHeight + 5) {
                        chunk[BlockPos(X: i, Y: k, Z: j)] = treeTrunk
                    }
                }
            }
        }
        
        return chunk
    }
}
