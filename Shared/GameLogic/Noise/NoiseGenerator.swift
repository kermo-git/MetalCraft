
protocol NoiseGenerator {
    func signedNoise2D(_ x: Float, _ y: Float) -> Float
    func signedNoise3D(_ x: Float, _ y: Float, _ z: Float) -> Float
}

extension NoiseGenerator {
    func noise2D(_ x: Float, _ y: Float) -> Float {
        return 0.5 * signedNoise2D(x, y) + 0.5
    }
    
    func turbulence2D(_ x: Float, _ y: Float) -> Float {
        let value = signedNoise2D(x, y)
        return value > 0 ? value : -value
    }
    
    func noise3D(_ x: Float, _ y: Float, _ z: Float) -> Float {
        return 0.5 * signedNoise3D(x, y, z) + 0.5
    }
    
    func turbulence3D(_ x: Float, _ y: Float, _ z: Float) -> Float {
        let value = signedNoise3D(x, y, z)
        return value > 0 ? value : -value
    }
}

struct FractalNoise: NoiseGenerator {
    let startFrequency: Float
    let octaves: Int
    let persistence: Float
    let generator = SimplexNoise()
    
    init(startFrequency: Float, octaves: Int = 1, persistence: Float = 0.5) {
        self.startFrequency = startFrequency
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise2D(_ x: Float, _ y: Float) -> Float {
        var total: Float = 0;
        var frequency: Float = startFrequency;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for _ in 0..<octaves {
            total += amplitude * generator.signedNoise2D(frequency * x, frequency * y);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
    
    func signedNoise3D(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var total: Float = 0;
        var frequency: Float = startFrequency;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for _ in 0..<octaves {
            total += amplitude * generator.signedNoise3D(frequency * x, frequency * y, frequency * z);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct TerrainNoise {
    let generator: NoiseGenerator
    let minTerrainHeight: Int
    let heightRange: Float
    
    init(generator: NoiseGenerator,
         minTerrainHeight: Int,
         heightRange: Int) {
        
        self.generator = generator
        self.minTerrainHeight = minTerrainHeight
        self.heightRange = Float(heightRange)
    }
    
    func terrainHeight(_ pos: Int3) -> Int {
        let x = Float(pos.x)
        let z = Float(pos.z)
        
        return minTerrainHeight + Int(generator.noise2D(x, z) * heightRange)
    }
}
