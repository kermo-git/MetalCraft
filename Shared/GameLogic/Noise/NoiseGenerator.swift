import simd

protocol Noise2D {
    func signedNoise(_ pos: Double2) -> Double
}

extension Noise2D {
    func noise(_ pos: Double2) -> Double {
        return 0.5 * signedNoise(pos) + 0.5
    }
    
    func turbulence(_ pos: Double2) -> Double {
        return abs(signedNoise(pos))
    }
}

protocol Noise3D {
    func signedNoise(_ pos: Double3) -> Double
}

extension Noise3D {
    func noise(_ pos: Double3) -> Double {
        return 0.5 * signedNoise(pos) + 0.5
    }
    
    func turbulence(_ pos: Double3) -> Double {
        return abs(signedNoise(pos))
    }
}

struct FractalNoise2D: Noise2D {
    let seed: UInt32
    let octaves: UInt32
    let persistence: Double
    
    init(seed: UInt32 = 0, octaves: UInt32 = 1, persistence: Double = 0.5) {
        self.seed = seed
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ pos: Double2) -> Double {
        var total: Double = 0;
        var frequency: Double = 1;
        var amplitude: Double = 1;
        var max_value: Double = 0;

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
    let seed: UInt32
    let octaves: UInt32
    let persistence: Double
    
    init(seed: UInt32 = 0, octaves: UInt32 = 1, persistence: Double = 0.5) {
        self.seed = seed
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ pos: Double3) -> Double {
        var total: Double = 0;
        var frequency: Double = 1;
        var amplitude: Double = 1;
        var max_value: Double = 0;

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
    let multiplier: Double
    let minTerrainHeight: Int32
    let heightRange: Double
    
    init(noise: Noise2D,
         unitBlocks: Int,
         minTerrainHeight: Int32,
         heightRange: Int32) {
        
        self.noise = noise
        self.multiplier = 1 / Double(unitBlocks)
        self.minTerrainHeight = minTerrainHeight
        self.heightRange = Double(heightRange)
    }
    
    func terrainHeight(_ pos: Int3) -> Int32 {
        let noise_pos = Double2(Double(pos.x), Double(pos.z)) * multiplier
        return minTerrainHeight + Int32(noise.noise(noise_pos) * heightRange)
    }
}
