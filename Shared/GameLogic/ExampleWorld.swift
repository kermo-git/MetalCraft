class ExampleWorld: WorldGenerator {
    let terrain = TerrainNoise(
        generator: FractalNoise(startFrequency: 1/200,
                                octaves: 3, persistence: 0.5),
        minTerrainHeight: 60,
        heightRange: 30
    )
    let treeGenerator = StructureGenerator(gridCellSize: 8)
    let tree: Structure
    let dirtLayerHeight = 5
    let textureNames: [String]
    let blocks: [Block]
    
    let STONE = 0
    let DIRT = 1
    let GRASS = 2
    let WOOD = 3
    let LEAVES = 4
    
    init() {
        tree = buildTree(wood_id: WOOD, leaves_id: LEAVES)
        
        let textureNames = [
            "stone",
            "dirt",
            "dirt_grass",
            "grass",
            "wood_bark",
            "wood_cut",
            "leaves"
        ]
        self.textureNames = textureNames
        
        func texID(_ textureName: String) -> Int {
            return textureNames.firstIndex(of: textureName) ?? 0
        }
        
        blocks = [
            Block(topTextureID: texID("stone"),
                  sideTextureID: texID("stone"),
                  bottomTextureID: texID("stone")),
            
            Block(topTextureID: texID("dirt"),
                  sideTextureID: texID("dirt"),
                  bottomTextureID: texID("dirt")),
            
            Block(topTextureID: texID("grass"),
                  sideTextureID: texID("dirt_grass"),
                  bottomTextureID: texID("dirt")),
            
            Block(topTextureID: texID("wood_cut"),
                  sideTextureID: texID("wood_bark"),
                  bottomTextureID: texID("wood_cut")),
            
            Block(topTextureID: texID("leaves"),
                  sideTextureID: texID("leaves"),
                  bottomTextureID: texID("leaves"))
        ]
    }

    func generateChunk(_ pos: Int2) -> Chunk {
        let chunk = Chunk()
        
        for tree_cell_x in (2*pos.x - 1)...(2*pos.x + 2) {
            for tree_cell_z in (2*pos.y - 1)...(2*pos.y + 2) {
                var (treePos, _) = treeGenerator.findStructure(tree_cell_x, tree_cell_z)
                
                treePos.y = terrain.terrainHeight(treePos)
                treePos.x -= 2
                treePos.z -= 2
                
                chunk.placeStructure(chunk_pos: pos, struct_NW_corner: treePos, structure: tree)
            }
        }
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = Int3(i, 0, j)
                let globalPos = getGlobalBlockPos(chunkPos: pos, localBlockPos: localPos)
                
                let terrainHeight = terrain.terrainHeight(globalPos)
                
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

func buildTree(wood_id: Int, leaves_id: Int) -> Structure {
    let A = AIR_ID
    let W = wood_id
    let L = leaves_id

    let trunk_layer = [[A, A, A, A, A],
                       [A, A, A, A, A],
                       [A, A, W, A, A],
                       [A, A, A, A, A],
                       [A, A, A, A, A]]
    
    let canopy_base = [[A, L, L, L, A],
                       [L, L, L, L, L],
                       [L, L, W, L, L],
                       [L, L, L, L, L],
                       [A, L, L, L, A]]
    
    let canopy_middle = [[A, A, A, A, A],
                         [A, L, L, L, A],
                         [A, L, W, L, A],
                         [A, L, L, L, A],
                         [A, A, A, A, A]]
    
    let canopy_top = [[A, A, A, A, A],
                      [A, A, L, A, A],
                      [A, L, L, L, A],
                      [A, A, L, A, A],
                      [A, A, A, A, A]]
    
    return Structure(blocks: [
        trunk_layer, trunk_layer, trunk_layer,
        canopy_base, canopy_base, canopy_base,
        canopy_middle, canopy_middle,
        canopy_top
    ])
}
