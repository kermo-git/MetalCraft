
protocol Noise2D {
    func signedNoise(_ x: Float, _ y: Float) -> Float
}

extension Noise2D {
    func noise(_ x: Float, _ y: Float) -> Float {
        return 0.5 * signedNoise(x, y) + 0.5
    }
    
    func turbulence(_ x: Float, _ y: Float) -> Float {
        return abs(signedNoise(x, y))
    }
}

protocol Noise3D {
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float
}

extension Noise3D {
    func noise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        return 0.5 * signedNoise(x, y, z) + 0.5
    }
    
    func turbulence(_ x: Float, _ y: Float, _ z: Float) -> Float {
        return abs(signedNoise(x, y, z))
    }
}

struct FractalNoise2D: Noise2D {
    let startFrequency: Float
    let octaves: Int
    let persistence: Float
    let noise: Noise2D = Simplex2D()
    
    init(startFrequency: Float, octaves: Int = 1, persistence: Float = 0.5) {
        self.startFrequency = startFrequency
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ x: Float, _ y: Float) -> Float {
        var total: Float = 0;
        var frequency: Float = startFrequency;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for _ in 0..<octaves {
            total += amplitude * noise.signedNoise(frequency * x, frequency * y);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct FractalNoise3D: Noise3D {
    let startFrequency: Float
    let octaves: Int
    let persistence: Float
    let noise: Noise3D = Simplex3D()
    
    init(startFrequency: Float, octaves: Int = 1, persistence: Float = 0.5) {
        self.startFrequency = startFrequency
        self.octaves = octaves
        self.persistence = persistence
    }
    
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var total: Float = 0;
        var frequency: Float = startFrequency;
        var amplitude: Float = 1;
        var max_value: Float = 0;

        for _ in 0..<octaves {
            total += amplitude * noise.signedNoise(frequency * x, frequency * y, frequency * z);
            max_value += amplitude
            amplitude *= persistence
            frequency *= 2
        }
        return total / max_value
    }
}

struct TerrainNoise {
    let noise: Noise2D
    let minTerrainHeight: Int
    let heightRange: Float
    
    init(noise: Noise2D,
         minTerrainHeight: Int,
         heightRange: Int) {
        
        self.noise = noise
        self.minTerrainHeight = minTerrainHeight
        self.heightRange = Float(heightRange)
    }
    
    func terrainHeight(_ pos: Int3) -> Int {
        let x = Float(pos.x)
        let z = Float(pos.z)
        
        return minTerrainHeight + Int(noise.noise(x, z) * heightRange)
    }
}
