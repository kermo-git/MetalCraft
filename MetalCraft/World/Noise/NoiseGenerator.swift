
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
