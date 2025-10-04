private let MASK = 255

func createRandomVariants(_ n_variants: Int) -> [Int] {
    var result = Array(repeating: 0, count: MASK + 1)
    for i in 0...MASK {
        result[i] = Int.random(in: 0..<n_variants)
    }
    return result
}

func createWeightedVariants(_ probabilities: [Float]) -> [Int] {
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

class StructureGenerator<Biome: Hashable> {
    private var hashTable: [Int] = []
    private var structures: [Biome:[Int]] = [:]
    
    init() {
        for i in 0...MASK {
            hashTable.append(i)
        }
        hashTable.shuffle()
        
        for i in 0...MASK {
            hashTable.append(hashTable[i])
        }
    }
    
    func registerStructures(biome: Biome, probabilities: [Float]) {
        structures[biome] = createWeightedVariants(probabilities)
    }
    
    func registerStructures(biome: Biome, n_variants: Int) {
        structures[biome] = createRandomVariants(n_variants)
    }
    
    func findStructure(_ gridCellX: Int, _ gridCellZ: Int) -> (Int3, Int) {
        let hash = hashTable[hashTable[gridCellX & MASK] + gridCellZ & MASK]
        let x = 8 * gridCellX + hash & 7
        let z = 8 * gridCellZ + (hash >> 3) & 7
        return (Int3(x, 0, z), hash)
    }
    
    func getStructureVariant(_ biome: Biome, _ hash: Int) -> Int {
        return structures[biome]![hash]
    }
}
