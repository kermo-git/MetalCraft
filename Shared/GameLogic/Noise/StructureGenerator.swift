private let MASK = 255

struct StructureVariant<T: Hashable> {
    let type: T
    let blockID: [Int]
    let layerIndexes: [Int]
    let probability: Float?
}

class StructureGenerator<B: Hashable, S: Hashable> {
    private var structure_types: [S: Structure] = [:]
    private var structure_variants: [B : [StructureVariant<S>]] = [:]
    
    private var hash_table: [Int] = []
    private var structure_variant_index: [B : [Int]] = [:]
    
    init() {
        for i in 0...MASK {
            hash_table.append(i)
        }
        hash_table.shuffle()
        
        for i in 0...MASK {
            hash_table.append(hash_table[i])
        }
    }
    
    func addStructureType(key: S, structure: Structure) {
        structure_types[key] = structure
    }
    
    func addStructurevariant(biome: B, structureType: S, blockID: [Int], layerIndexes: [Int], probability: Float? = nil) {
        if !structure_variants.contains(where: {$0.key == biome}) {
            structure_variants[biome] = []
        }
        structure_variants[biome]?.append(StructureVariant(
            type: structureType,
            blockID: blockID,
            layerIndexes: layerIndexes,
            probability: probability
        ))
    }
    
    func compile() {
        for (biome, variants) in structure_variants {
            var probabilities: [Float] = []
            var equal_probabilities = false
            
            for variant in variants {
                if let probability = variant.probability {
                    probabilities.append(probability)
                } else {
                    equal_probabilities = true
                    break
                }
            }
            if equal_probabilities {
                structure_variant_index[biome] = createRandomVariants(variants.count)
            } else {
                structure_variant_index[biome] = createWeightedVariants(probabilities)
            }
        }
    }
    
    
    func findNearbyStructures(_ chunkPos: Int2) -> [(Int3, Int)] {
        var result: [(Int3, Int)] = []
        
        for gridCellX in (2*chunkPos.x - 1)...(2*chunkPos.x + 2) {
            for gridCellZ in (2*chunkPos.y - 1)...(2*chunkPos.y + 2) {
                let hash = hash_table[hash_table[gridCellX & MASK] + gridCellZ & MASK]
                let x = 8 * gridCellX + hash & 7
                let z = 8 * gridCellZ + (hash >> 3) & 7
                result.append((Int3(x, 0, z), hash))
            }
        }
        return result
    }
    
    func getStructureVariant(_ biome: B, _ hash: Int) -> (Structure, StructureVariant<S>) {
        let index = structure_variant_index[biome]![hash]
        let variant = structure_variants[biome]![index]
        return (structure_types[variant.type]!, variant)
    }
}

private func createRandomVariants(_ n_variants: Int) -> [Int] {
    var result = Array(repeating: 0, count: MASK + 1)
    for i in 0...MASK {
        result[i] = Int.random(in: 0..<n_variants)
    }
    return result
}

private func createWeightedVariants(_ probabilities: [Float]) -> [Int] {
    var cumulativeProbabilities = [probabilities[0]]
    for probability in probabilities[1...] {
        cumulativeProbabilities.append(
            min(1, probability + cumulativeProbabilities.last!)
        )
    }
    var result = Array(repeating: 0, count: MASK + 1)
    for i in 0...MASK {
        let variantChoice = Float.random(in: 0...1)
        
        for (v, probability) in cumulativeProbabilities.enumerated() {
            if variantChoice < probability {
                result[i] = v
                break
            }
        }
    }
    return result
}
