
protocol Noise2D {
    func signedNoise(_ pos: Float2) -> Float
}

extension Noise2D {
    func noise(_ pos: Float2) -> Float {
        return 0.5 * signedNoise(pos) + 0.5
    }
    
    func turbulence(_ pos: Float2) -> Float {
        return abs(signedNoise(pos))
    }
}

protocol Noise3D {
    func signedNoise(_ pos: Float3) -> Float
}

extension Noise3D {
    func noise(_ pos: Float3) -> Float {
        return 0.5 * signedNoise(pos) + 0.5
    }
    
    func turbulence(_ pos: Float3) -> Float {
        return abs(signedNoise(pos))
    }
}

struct FractalNoise2D: Noise2D {
    let seed: UInt64
    let octaves: UInt64
    let persistence: Float
    
    init(seed: UInt64 = 0, octaves: UInt64 = 1, persistence: Float = 0.5) {
        self.seed = seed
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ pos: Float2) -> Float {
        var total: Float = 0;
        var frequency: Float = 1;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for i in 0..<octaves {
            total += amplitude * simplex2D(seed + i, frequency * pos);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct FractalNoise3D: Noise3D {
    let seed: UInt64
    let octaves: UInt64
    let persistence: Float
    
    init(seed: UInt64 = 0, octaves: UInt64 = 1, persistence: Float = 0.5) {
        self.seed = seed
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ pos: Float3) -> Float {
        var total: Float = 0;
        var frequency: Float = 1;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for i in 0..<octaves {
            total += amplitude * simplex3D(seed + i, frequency * pos);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct TerrainNoise {
    let noise: Noise2D
    let multiplier: Float
    let minTerrainHeight: Int
    let heightRange: Float
    
    init(noise: Noise2D,
         unitBlocks: Int,
         minTerrainHeight: Int,
         heightRange: Int) {
        
        self.noise = noise
        self.multiplier = 1 / Float(unitBlocks)
        self.minTerrainHeight = minTerrainHeight
        self.heightRange = Float(heightRange)
    }
    
    func terrainHeight(_ pos: Int3) -> Int {
        let noise_pos = Float2(Float(pos.x), Float(pos.z)) * multiplier
        return minTerrainHeight + Int(noise.noise(noise_pos) * heightRange)
    }
}
