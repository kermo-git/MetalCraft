
let grass: Block = .SOLID_BLOCK(topTexture: .GRASS,
                                sideTexture: .DIRT_GRASS,
                                bottomTexture: .DIRT)

let flowers: Block = .SOLID_BLOCK(topTexture: .WHITE_FLOWERS,
                                  sideTexture: .DIRT_GRASS,
                                  bottomTexture: .DIRT)

class WorldGenerator {
    let generator = SimplexNoise()
    let grassGenerator = SimplexNoise()
    
    let NOISE_UNIT_BLOCKS: Float = 20
    let BASE_HEIGHT: Int = 10
    let NOISE_RANGE: Float = 10
    
    func terrainHeight(pos: BlockPos) -> Int {
        let noiseX = Float(pos.X) / NOISE_UNIT_BLOCKS
        let noiseY = Float(pos.Z) / NOISE_UNIT_BLOCKS
        
        let noiseValue = generator.noise(noiseX, noiseY, 0)
        return BASE_HEIGHT + Int(noiseValue * NOISE_RANGE)
    }
    
    func isFlowers(pos: BlockPos) -> Bool {
        let noiseX = Float(pos.X)
        let noiseY = Float(pos.Z)
        
        let noiseValue = grassGenerator.noise(noiseX, noiseY, 0)
        return noiseValue > 0.7
    }
    
    func generateChunk(pos: ChunkPos) -> Chunk {
        var chunk = Chunk()
        
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = BlockPos(X: i, Y: 0, Z: j)
                let globalPos = getGlobalPos(chunk: pos, local: localPos)
                let terrainHeight = terrainHeight(pos: globalPos)
                
                for k in 0..<terrainHeight {
                    chunk[BlockPos(X: i, Y: k, Z: j)] = isFlowers(pos: globalPos) ? flowers : grass
                }
            }
        }
        
        return chunk
    }
}
