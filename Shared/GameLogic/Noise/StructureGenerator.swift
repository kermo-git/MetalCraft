private let MASK = 255

struct StructureInfo {
    let localX: Int
    let localZ: Int
    let variantID: Int
}

class StructureGenerator {
    let gridCellSize: Int
    private var hashTable: [Int] = []
    private var structures: [StructureInfo] = []
    
    init(gridCellSize: Int,
         variantCount: Int = 1,
         variantProbabilities: [Float] = []) {
        
        self.gridCellSize = gridCellSize
        
        var cumulativeProbabilities: [Float] = []
        if variantProbabilities.count > 0 {
            cumulativeProbabilities = [variantProbabilities[0]]
            for probability in variantProbabilities[1...] {
                cumulativeProbabilities.append(
                    min(1, probability + cumulativeProbabilities.last!)
                )
            }
        }
        for i in 0...MASK {
            hashTable.append(i)
            var variantID = 0
            
            if variantProbabilities.count > 0 {
                let variantChoice = Float.random(in: 0...1)
                
                for (v, probability) in cumulativeProbabilities.enumerated() {
                    if variantChoice < probability {
                        variantID = v
                        break
                    }
                }
            } else {
                variantID = Int.random(in: 0..<variantCount)
            }
            structures.append(
                StructureInfo(
                    localX: Int.random(in: 0...(gridCellSize-1)),
                    localZ: Int.random(in: 0...(gridCellSize-1)),
                    variantID: variantID
                )
            )
        }
        hashTable.shuffle()
        
        for i in 0...MASK {
            hashTable.append(hashTable[i])
        }
    }
    
    func findStructure(_ gridCellX: Int, _ gridCellZ: Int) -> (Int3, Int) {
        let hash = hashTable[hashTable[gridCellX & MASK] + gridCellZ & MASK]
        let structure = structures[hash]
        return (
            Int3(
                x: gridCellSize * gridCellX + structure.localX,
                y: 0,
                z: gridCellSize * gridCellZ + structure.localZ
            ),
            structure.variantID
        )
    }
}
