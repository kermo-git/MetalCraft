
protocol NoiseGenerator {
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float
}

extension NoiseGenerator {
    func noise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        return 0.5 * signedNoise(x, y, z) + 0.5
    }
    
    func turbulence(_ x: Float, _ y: Float, _ z: Float) -> Float {
        let value = signedNoise(x, y, z)
        return value > 0 ? value : -value
    }
}

struct FractalNoise: NoiseGenerator {
    let octaves: Int
    let persistence: Float
    let generator: NoiseGenerator = SimplexNoise()
    
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var total: Float = 0;
        var frequency: Float = 1;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for _ in 0..<octaves {
            total += amplitude * generator.signedNoise(frequency * x, frequency * y, frequency * z);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct TerrainNoise {
    let generator: NoiseGenerator
    let unitSquareBlocks: Float
    let minTerrainHeight: Int
    let heightRange: Float
    
    func signedNoise(_ pos: BlockPos) -> Float {
        let noiseX = Float(pos.X) / unitSquareBlocks
        let noiseY = Float(pos.Z) / unitSquareBlocks
        
        return generator.signedNoise(noiseX, noiseY, 0)
    }
    
    func noise(_ pos: BlockPos) -> Float {
        return 0.5 * signedNoise(pos) + 0.5
    }
    
    func turbulence(_ pos: BlockPos) -> Float {
        let value = signedNoise(pos)
        return value > 0 ? value : -value
    }
    
    func terrainHeight(_ pos: BlockPos) -> Int {
        return minTerrainHeight + Int(noise(pos) * heightRange)
    }
    
    func turbulentTerrainHeight(_ pos: BlockPos) -> Int {
        return minTerrainHeight + Int(turbulence(pos) * heightRange)
    }
}
