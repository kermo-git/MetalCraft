class ExampleWorld: WorldGenerator {
    let textureNames: [String]
    let blocks: [Block]
    let blockID: [String: Int]
    
    let terrain = TerrainNoise(
        generator: FractalNoise(startFrequency: 1/200,
                                octaves: 3, persistence: 0.5),
        minTerrainHeight: 60,
        heightRange: 30
    )
    let treeGenerator: StructureGenerator
    let trees: [Biome: [Structure]]
    let dirtLayerHeight = 5
    
    init() {
        let block_info = [
            "stone": BlockInfo(topTexture: "stone"),
            "dirt": BlockInfo(topTexture: "dirt"),
            "sand": BlockInfo(topTexture: "sand"),
            
            "dry_grass": BlockInfo(topTexture: "dry_grass",
                                   sideTexture: "dry_grass_dirt",
                                   bottomTexture: "dirt"),
            "dry_grass_leaves_1": BlockInfo(topTexture: "dry_grass_leaves_1",
                                             sideTexture: "dry_grass_dirt",
                                             bottomTexture: "dirt"),
            "dry_grass_leaves_2": BlockInfo(topTexture: "dry_grass_leaves_2",
                                             sideTexture: "dry_grass_dirt",
                                             bottomTexture: "dirt"),
            "dry_grass_leaves_3": BlockInfo(topTexture: "dry_grass_leaves_3",
                                             sideTexture: "dry_grass_dirt",
                                             bottomTexture: "dirt"),
            
            "warm_grass": BlockInfo(topTexture: "warm_grass",
                                    sideTexture: "warm_grass_dirt",
                                    bottomTexture: "dirt"),
            "warm_grass_flowers_1": BlockInfo(topTexture: "warm_grass_flowers_1",
                                              sideTexture: "warm_grass_dirt",
                                              bottomTexture: "dirt"),
            "warm_grass_flowers_2": BlockInfo(topTexture: "warm_grass_flowers_2",
                                              sideTexture: "warm_grass_dirt",
                                              bottomTexture: "dirt"),
            "warm_grass_flowers_3": BlockInfo(topTexture: "warm_grass_flowers_3",
                                              sideTexture: "warm_grass_dirt",
                                              bottomTexture: "dirt"),
            
            "cold_grass": BlockInfo(topTexture: "cold_grass",
                                    sideTexture: "cold_grass_dirt",
                                    bottomTexture: "dirt"),
            "cold_grass_flowers_1": BlockInfo(topTexture: "cold_grass_flowers_1",
                                              sideTexture: "cold_grass_dirt",
                                              bottomTexture: "dirt"),
            "cold_grass_flowers_2": BlockInfo(topTexture: "cold_grass_flowers_2",
                                              sideTexture: "cold_grass_dirt",
                                              bottomTexture: "dirt"),
            "cold_grass_flowers_3": BlockInfo(topTexture: "cold_grass_flowers_3",
                                              sideTexture: "cold_grass_dirt",
                                              bottomTexture: "dirt"),
            
            "snow_dirt": BlockInfo(topTexture: "snow",
                                   sideTexture: "snow_dirt",
                                   bottomTexture: "dirt"),
            
            "autumn_green_leaves": BlockInfo(topTexture: "autumn_green_leaves"),
            "autumn_yellow_leaves": BlockInfo(topTexture: "autumn_yellow_leaves"),
            "autumn_orange_leaves": BlockInfo(topTexture: "autumn_orange_leaves"),
            "warm_leaves": BlockInfo(topTexture: "warm_leaves"),
            "spruce_leaves": BlockInfo(topTexture: "spruce_leaves"),
            "snow_spruce_leaves": BlockInfo(topTexture: "snow",
                                            sideTexture: "snow_spruce_leaves",
                                            bottomTexture: "spruce_leaves"),
            
            "brown_wood": BlockInfo(topTexture: "brown_wood_cut",
                                    sideTexture: "brown_wood_bark"),
            "gray_wood": BlockInfo(topTexture: "gray_wood_cut",
                                    sideTexture: "gray_wood_bark")
        ]
        
        let (blockID, textureNames, blocks) = compileBlocks(block_info)
        
        self.textureNames = textureNames
        self.blocks = blocks
        self.blockID = blockID
        
        var autumn_trees = (2...4).map() {
            trunk_height in buildTree(trunk_height: trunk_height,
                                      wood_id: blockID["gray_wood"]!,
                                      leaves_id: blockID["autumn_green_leaves"]!)
        }
        autumn_trees.append(contentsOf: (2...4).map() {
            trunk_height in buildTree(trunk_height: trunk_height,
                                      wood_id: blockID["gray_wood"]!,
                                      leaves_id: blockID["autumn_yellow_leaves"]!)
        })
        autumn_trees.append(contentsOf: (2...4).map() {
            trunk_height in buildTree(trunk_height: trunk_height,
                                      wood_id: blockID["gray_wood"]!,
                                      leaves_id: blockID["autumn_orange_leaves"]!)
        })
        
        trees = [
            .AUTUMN_FOREST: autumn_trees,
            .LUSH_FOREST: (2...4).map() {
                trunk_height in buildTree(trunk_height: trunk_height,
                                          wood_id: blockID["brown_wood"]!,
                                          leaves_id: blockID["warm_leaves"]!)
            },
            .SPRUCE_FOREST: (2...4).map() {
                trunk_height in buildSpruceTree(trunk_height: trunk_height,
                                                wood_id: blockID["brown_wood"]!,
                                                leaves_id: blockID["spruce_leaves"]!)
            },
            .SNOWY_FOREST: (2...4).map() {
                trunk_height in buildSpruceTree(trunk_height: trunk_height,
                                                wood_id: blockID["brown_wood"]!,
                                                leaves_id: blockID["spruce_leaves"]!,
                                                top_layer_leaves_id: blockID["snow_spruce_leaves"]!)
            },
        ]
        treeGenerator = StructureGenerator()
        treeGenerator.registerStructures(biome: .AUTUMN_FOREST,
                                         n_variants: trees[.AUTUMN_FOREST]!.count)
        treeGenerator.registerStructures(biome: .LUSH_FOREST,
                                         n_variants: trees[.LUSH_FOREST]!.count)
        treeGenerator.registerStructures(biome: .SPRUCE_FOREST,
                                         n_variants: trees[.SPRUCE_FOREST]!.count)
        treeGenerator.registerStructures(biome: .SNOWY_FOREST,
                                         n_variants: trees[.SNOWY_FOREST]!.count)
    }
    let rotations: [BlockOrientation] = [.NONE, .Y90, .YNEG90, .Y180]
    
    let biomes = FractalNoise(startFrequency: 1/200)
    
    func findBiome(_ pos: Int3) -> Biome {
        let biome = biomes.signedNoise2D(Float(pos.x), Float(pos.z))
        
        if (biome < -0.6) {
            return .AUTUMN_FOREST
        } else if (biome < 0) {
            return .LUSH_FOREST
        } else if (biome < 0.6) {
            return .SPRUCE_FOREST
        } else {
            return .SNOWY_FOREST
        }
    }

    func generateChunk(_ pos: Int2) -> Chunk {
        let chunk = Chunk()
        
        for tree_cell_x in (2*pos.x - 1)...(2*pos.x + 2) {
            for tree_cell_z in (2*pos.y - 1)...(2*pos.y + 2) {
                let (trunkPos, hash) = treeGenerator.findStructure(tree_cell_x, tree_cell_z)
                let biome = findBiome(trunkPos)
                let variantID = treeGenerator.getStructureVariant(biome, hash)
                let structure = trees[biome]![variantID]
                
                let tree_nw_corner = Int3(
                    x: trunkPos.x - structure.lengthX/2,
                    y: terrain.terrainHeight(trunkPos),
                    z: trunkPos.z - structure.lengthZ/2
                )
                chunk.placeStructure(chunk_pos: pos,
                                     struct_NW_corner: tree_nw_corner,
                                     structure: structure)
            }
        }
        for i in 0..<CHUNK_SIDE {
            for j in 0..<CHUNK_SIDE {
                let localPos = Int3(i, 0, j)
                let globalPos = getGlobalBlockPos(chunkPos: pos, localBlockPos: localPos)
                
                let terrainHeight = terrain.terrainHeight(globalPos)
                let ground_block_id: Int
                
                switch findBiome(globalPos) {
                case .AUTUMN_FOREST:
                    if Float.random(in: 0...1) > 0.4 {
                        ground_block_id = blockID["dry_grass"]!
                    } else {
                        ground_block_id = blockID[[
                            "dry_grass_leaves_1",
                            "dry_grass_leaves_2",
                            "dry_grass_leaves_3"
                        ].randomElement()!]!
                    }
                case .LUSH_FOREST:
                    if Float.random(in: 0...1) > 0.2 {
                        ground_block_id = blockID["warm_grass"]!
                    } else {
                        ground_block_id = blockID[[
                            "warm_grass_flowers_1",
                            "warm_grass_flowers_2",
                            "warm_grass_flowers_3"
                        ].randomElement()!]!
                    }
                case .SPRUCE_FOREST:
                    if Float.random(in: 0...1) > 0.2 {
                        ground_block_id = blockID["cold_grass"]!
                    } else {
                        ground_block_id = blockID[[
                            "cold_grass_flowers_1",
                            "cold_grass_flowers_2",
                            "cold_grass_flowers_3"
                        ].randomElement()!]!
                    }
                case .SNOWY_FOREST:
                    ground_block_id = blockID["snow_dirt"]!
                }
                
                for k in 0..<(terrainHeight - dirtLayerHeight) {
                    chunk.set(Int3(i, k, j), blockID["stone"]!)
                }
                for k in (terrainHeight - dirtLayerHeight)...(terrainHeight - 2) {
                    chunk.set(Int3(i, k, j), blockID["dirt"]!)
                }
                chunk.set(Int3(i, terrainHeight - 1, j),
                          ground_block_id,
                          rotations.randomElement()!)
            }
        }
        chunk.determineYBoundaries()
        
        return chunk
    }
}

func buildTree(trunk_height: Int, wood_id: Int, leaves_id: Int) -> Structure {
    let A = AIR_ID
    let W = wood_id
    let L = leaves_id
    
    var layers: [[[Int]]] = []
    
    for _ in 0..<trunk_height {
        layers.append(
            [[A, A, A, A, A],
             [A, A, A, A, A],
             [A, A, W, A, A],
             [A, A, A, A, A],
             [A, A, A, A, A]]
        )
    }
    for _ in 0..<3 {
        layers.append(
            [[A, L, L, L, A],
             [L, L, L, L, L],
             [L, L, W, L, L],
             [L, L, L, L, L],
             [A, L, L, L, A]]
        )
    }
    for _ in 0..<2 {
        layers.append(
            [[A, A, A, A, A],
             [A, L, L, L, A],
             [A, L, W, L, A],
             [A, L, L, L, A],
             [A, A, A, A, A]]
        )
    }
    layers.append(
        [[A, A, A, A, A],
         [A, A, L, A, A],
         [A, L, L, L, A],
         [A, A, L, A, A],
         [A, A, A, A, A]]
    )
    return Structure(blocks: layers)
}

func buildSpruceTree(trunk_height: Int, wood_id: Int,
                     leaves_id: Int, top_layer_leaves_id: Int = -1) -> Structure {
    let A = AIR_ID
    let W = wood_id
    let L = leaves_id
    let T = if top_layer_leaves_id == -1 {
        leaves_id
    } else {
        top_layer_leaves_id
    }
    
    var layers: [[[Int]]] = []
    
    for _ in 0..<trunk_height {
        layers.append(
            [[A, A, A, A, A, A, A],
             [A, A, A, A, A, A, A],
             [A, A, A, A, A, A, A],
             [A, A, A, W, A, A, A],
             [A, A, A, A, A, A, A],
             [A, A, A, A, A, A, A],
             [A, A, A, A, A, A, A]]
        )
    }
    layers.append(
        [[A, A, T, L, T, A, A],
         [A, L, L, L, L, L, A],
         [T, L, L, L, L, L, T],
         [L, L, L, W, L, L, L],
         [T, L, L, L, L, L, T],
         [A, L, L, L, L, L, A],
         [A, A, T, L, T, A, A]]
    )
    layers.append(
        [[A, A, A, T, A, A, A],
         [A, T, L, L, L, T, A],
         [A, L, L, L, L, L, A],
         [T, L, L, W, L, L, T],
         [A, L, L, L, L, L, A],
         [A, T, L, L, L, T, A],
         [A, A, A, T, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, T, L, T, A, A],
         [A, T, L, L, L, T, A],
         [A, L, L, W, L, L, A],
         [A, T, L, L, L, T, A],
         [A, A, T, L, T, A, A],
         [A, A, A, A, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, A, T, A, A, A],
         [A, A, L, L, L, A, A],
         [A, T, L, W, L, T, A],
         [A, A, L, L, L, A, A],
         [A, A, A, T, A, A, A],
         [A, A, A, A, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, T, L, T, A, A],
         [A, A, L, W, L, A, A],
         [A, A, T, L, T, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, T, A, A, A],
         [A, A, T, W, T, A, A],
         [A, A, A, T, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, L, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    )
    layers.append(
        [[A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, T, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A],
         [A, A, A, A, A, A, A]]
    )
    return Structure(blocks: layers)
}
