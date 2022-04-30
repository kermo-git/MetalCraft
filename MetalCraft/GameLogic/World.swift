
let sandGrass: Block = .SOLID_BLOCK(topTexture: .GRASS,
                                    sideTexture: .STONE_GRASS,
                                    bottomTexture: .STONE)

let treeTrunk: Block = .SOLID_BLOCK(topTexture: .TREE_CUT,
                                    sideTexture: .TREE_BARK,
                                    bottomTexture: .TREE_CUT)

class World {
    let generator = SimplexNoise()
    
    let NOISE_UNIT_BLOCKS: Float = 20
    let BASE_HEIGHT: Int = 10
    let NOISE_RANGE: Float = 10
    
    var chunks = ChunkMap()
    
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
    
    func getFaces() -> [BlockFace] {
        let centerPos = ChunkPos(X: 0, Z: 0)
        let northPos = centerPos.move(.NORTH)
        let southPos = centerPos.move(.SOUTH)
        let eastPos = centerPos.move(.EAST)
        let westPos = centerPos.move(.WEST)
        
        let centerChunk = generateChunk(pos: centerPos)
        let northChunk = generateChunk(pos: northPos)
        let southChunk = generateChunk(pos: southPos)
        let eastChunk = generateChunk(pos: eastPos)
        let westChunk = generateChunk(pos: westPos)
        
        var faces: [BlockFace] = []
        
        faces.append(contentsOf: getBlockFaces(chunkPos: centerPos, chunk: centerChunk))
        faces.append(contentsOf: getBlockFaces(chunkPos: northPos, chunk: northChunk))
        faces.append(contentsOf: getBlockFaces(chunkPos: southPos, chunk: southChunk))
        faces.append(contentsOf: getBlockFaces(chunkPos: eastPos, chunk: eastChunk))
        faces.append(contentsOf: getBlockFaces(chunkPos: westPos, chunk: westChunk))
        
        /*
        faces.append(contentsOf: getNorthBorderBlockFaces(southChunkPos: southPos,
                                                          southChunk: southChunk,
                                                          northChunk: centerChunk))
        
        faces.append(contentsOf: getNorthBorderBlockFaces(southChunkPos: centerPos,
                                                          southChunk: centerChunk,
                                                          northChunk: northChunk))
        
        faces.append(contentsOf: getWestBorderBlockFaces(eastChunkPos: eastPos,
                                                         eastChunk: eastChunk,
                                                         westChunk: centerChunk))
        
        faces.append(contentsOf: getWestBorderBlockFaces(eastChunkPos: centerPos,
                                                         eastChunk: centerChunk,
                                                         westChunk: westChunk))
        */
        return faces
    }
}
