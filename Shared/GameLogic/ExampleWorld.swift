enum Biome {
    case AUTUMN_FOREST
    case LUSH_FOREST
    case SPRUCE_FOREST
    case SNOWY_FOREST
}

enum StructureType {
    case TREE
    case SPRUCE_TREE
}

struct ExampleWorld: WorldGenerator, @unchecked Sendable {
    let textureNames: [String]
    let blocks: [Block]
    let blockID: [String: Int]
    
    let terrain = TerrainNoise(
        generator: FractalNoise(startFrequency: 1/200,
                                octaves: 3, persistence: 0.5),
        minTerrainHeight: 60,
        heightRange: 30
    )
    let structureTypes: [StructureType: Structure] = [
        StructureType.TREE: buildTree(),
        StructureType.SPRUCE_TREE: buildSpruceTree()
    ]
    let trees: [Biome: [StructureVariant<StructureType>]]
    let treeGenerator: StructureGenerator<Biome>
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
                                    sideTexture: "gray_wood_bark"),
            "birch_wood": BlockInfo(topTexture: "birch_wood_cut",
                                    sideTexture: "birch_wood_bark"),
        ]
        
        let (blockID, textureNames, blocks) = compileBlocks(block_info)
        
        self.textureNames = textureNames
        self.blocks = blocks
        self.blockID = blockID
        
        var autumn_trees: [StructureVariant<StructureType>] = []
        var lush_trees: [StructureVariant<StructureType>] = []
        
        for trunk_blocks in (2...4) {
            for canopy_bottom_blocks in (1...2) {
                for canopy_middle_blocks in (2...4) {
                    let layer_indexes = treeLayerRepeats(
                        trunk_blocks,
                        canopy_bottom_blocks,
                        canopy_middle_blocks
                    )
                    for wood_type in ["brown_wood", "birch_wood"] {
                        lush_trees.append(StructureVariant(
                            type: StructureType.TREE,
                            blockID: [blockID[wood_type]!, blockID["warm_leaves"]!],
                            layerIndexes: layer_indexes
                        ))
                    }
                    for wood_type in ["gray_wood", "birch_wood"] {
                        for leaf_color in ["green", "yellow", "orange"] {
                            autumn_trees.append(StructureVariant(
                                type: StructureType.TREE,
                                blockID: [blockID[wood_type]!, blockID["autumn_\(leaf_color)_leaves"]!],
                                layerIndexes: layer_indexes
                            ))
                        }
                    }
                }
            }
        }
        
        var spruce_trees: [StructureVariant<StructureType>] = []
        var snowy_spruce_trees: [StructureVariant<StructureType>] = []
        
        for trunk_blocks in (2...4) {
            for is_large in [false, true] {
                for is_tall in [false, true] {
                    let layer_indexes = spruceLayerRepeats(trunkBlocks: trunk_blocks, isLarge: is_large, isTall: is_tall)
                    
                    spruce_trees.append(StructureVariant(
                        type: StructureType.SPRUCE_TREE,
                        blockID: [blockID["brown_wood"]!, blockID["spruce_leaves"]!, blockID["spruce_leaves"]!],
                        layerIndexes: layer_indexes
                    ))
                    snowy_spruce_trees.append(StructureVariant(
                        type: StructureType.SPRUCE_TREE,
                        blockID: [blockID["brown_wood"]!, blockID["spruce_leaves"]!, blockID["snow_spruce_leaves"]!],
                        layerIndexes: layer_indexes
                    ))
                }
            }
        }
        
        trees = [
            .AUTUMN_FOREST: autumn_trees,
            .LUSH_FOREST: lush_trees,
            .SPRUCE_FOREST: spruce_trees,
            .SNOWY_FOREST: snowy_spruce_trees,
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
        var chunk = Chunk()
        
        for tree_cell_x in (2*pos.x - 1)...(2*pos.x + 2) {
            for tree_cell_z in (2*pos.y - 1)...(2*pos.y + 2) {
                let (trunkPos, hash) = treeGenerator.findStructure(tree_cell_x, tree_cell_z)
                let biome = findBiome(trunkPos)
                let variantID = treeGenerator.getStructureVariant(biome, hash)
                let structureVariant = trees[biome]![variantID]
                let structure = structureTypes[structureVariant.type]!
                
                let tree_nw_corner = Int3(
                    x: trunkPos.x - structure.lengthX/2,
                    y: terrain.terrainHeight(trunkPos),
                    z: trunkPos.z - structure.lengthZ/2
                )
                chunk.placeStructure(chunk_pos: pos,
                                     struct_NW_corner: tree_nw_corner,
                                     structure: structure,
                                     variant: structureVariant)
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
