struct StructureVariant<T: Hashable> {
    let type: T
    let blockID: [UInt16]
    let layerIndexes: [Int32]
}

class StructureGenerator<B: Hashable, S: Hashable> {
    private var structure_types: [S: Structure] = [:]
    private var structure_variants: [B : [StructureVariant<S>]] = [:]
    
    private let seed: UInt32
    
    init(_ seed: UInt32) {
        self.seed = seed
    }
    
    func addStructureType(key: S, structure: Structure) {
        structure_types[key] = structure
    }
    
    func addStructurevariant(biome: B, structureType: S,
                             blockID: [UInt16], layerIndexes: [Int32]) {
        if !structure_variants.contains(where: {$0.key == biome}) {
            structure_variants[biome] = []
        }
        structure_variants[biome]?.append(StructureVariant(
            type: structureType,
            blockID: blockID,
            layerIndexes: layerIndexes
        ))
    }
    
    func findNearbyStructures(_ chunkPos: Int2) -> [(Int3, Int)] {
        var result: [(Int3, Int)] = []
        
        for gridCellX in (2*chunkPos.x - 1)...(2*chunkPos.x + 2) {
            for gridCellZ in (2*chunkPos.y - 1)...(2*chunkPos.y + 2) {
                let hash = Int32(hash2D_raw(seed, Int2(gridCellX, gridCellZ)) & 255)
                let x = 8 * gridCellX + hash & 7
                let z = 8 * gridCellZ + (hash >> 3) & 7
                result.append((Int3(x, 0, z), Int(hash)))
            }
        }
        return result
    }
    
    func getStructureVariant(_ biome: B, _ hash: Int) -> (Structure, StructureVariant<S>) {
        let variants = structure_variants[biome]!
        let variant = variants[hash % variants.count]
        return (structure_types[variant.type]!, variant)
    }
}
