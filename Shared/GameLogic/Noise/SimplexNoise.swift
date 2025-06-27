import simd

let ONE_THIRD: Float = 1.0 / 3.0
let ONE_SIXTH: Float = 1.0 / 6.0

private func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
    switch (hash & 15) {
        case 0:  return  x + y
        case 1:  return -x + y
        case 2:  return  x - y
        case 3:  return -x - y
        case 4:  return  x + z
        case 5:  return -x + z
        case 6:  return  x - z
        case 7:  return -x - z
        case 8:  return  y + z
        case 9:  return -y + z
        case 10: return  y - z
        case 11: return -y - z
        case 12: return  x + y
        case 13: return -x + y
        case 14: return -y + z
        case 15: return -y - z
    default:
        return 0
    }
}

class SimplexNoise: NoiseGenerator {
    private let MASK = 255
    
    private var hashTable: [Int] = []
    
    init() {
        for i in 0...MASK {
            hashTable.append(i)
        }
        hashTable.shuffle()
        
        for i in 0...MASK {
            hashTable.append(hashTable[i])
        }
    }
    
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var s = (x + y + z) * ONE_THIRD;
        let i0 = Int(floor(x + s));
        let j0 = Int(floor(y + s));
        let k0 = Int(floor(z + s));
        
        s = Float(i0 + j0 + k0) * ONE_SIXTH;
        let u0 = x - Float(i0) + s;
        let v0 = y - Float(j0) + s;
        let w0 = z - Float(k0) + s;
        
        var i1: Int,
            j1: Int,
            k1: Int,
            i2: Int,
            j2: Int,
            k2: Int

        if (u0 > v0) {
            if (v0 > w0) {
                i1 = 1; j1 = 0; k1 = 0;
                i2 = 1; j2 = 1; k2 = 0;
            } else if (w0 > u0) {
                i1 = 0; j1 = 0; k1 = 1;
                i2 = 1; j2 = 0; k2 = 1;
            } else {
                i1 = 1; j1 = 0; k1 = 0;
                i2 = 1; j2 = 0; k2 = 1;
            }
        } else {
            if (w0 < u0) {
                i1 = 0; j1 = 1; k1 = 0;
                i2 = 1; j2 = 1; k2 = 0;
            } else if (w0 > v0) {
                i1 = 0; j1 = 0; k1 = 1;
                i2 = 0; j2 = 1; k2 = 1;
            } else {
                i1 = 0; j1 = 1; k1 = 0;
                i2 = 0; j2 = 1; k2 = 1;
            }
        }
        let u1 = u0 - Float(i1) + ONE_SIXTH;
        let v1 = v0 - Float(j1) + ONE_SIXTH;
        let w1 = w0 - Float(k1) + ONE_SIXTH;
        
        let u2 = u0 - Float(i2) + ONE_THIRD;
        let v2 = v0 - Float(j2) + ONE_THIRD;
        let w2 = w0 - Float(k2) + ONE_THIRD;
        
        let u3 = u0 - 0.5;
        let v3 = v0 - 0.5;
        let w3 = w0 - 0.5;
        
        var n0: Float = 0.0
        var t = 0.6 - (u0 * u0 + v0 * v0 + w0 * w0)
        if (t >= 0) {
            let h = hash(i0, j0, k0)
            n0 = t * t * t * t * grad(h, u0, v0, w0)
        }
        
        var n1: Float = 0.0
        t = 0.6 - (u1 * u1 + v1 * v1 + w1 * w1)
        if (t >= 0) {
            let h = hash(i0 + i1, j0 + j1, k0 + k1)
            n1 = t * t * t * t * grad(h, u1, v1, w1)
        }
        
        var n2: Float = 0.0
        t = 0.6 - (u2 * u2 + v2 * v2 + w2 * w2)
        if (t >= 0) {
            let h = hash(i0 + i2, j0 + j2, k0 + k2)
            n2 = t * t * t * t * grad(h, u2, v2, w2)
        }
        
        var n3: Float = 0.0
        t = 0.6 - (u3 * u3 + v3 * v3 + w3 * w3)
        if (t >= 0) {
            let h = hash(i0 + 1, j0 + 1, k0 + 1)
            n3 = t * t * t * t * grad(h, u3, v3, w3)
        }
        
        return 32 * (n0 + n1 + n2 + n3)
    }
    
    private func hash(_ x: Int, _ y: Int, _ z: Int) -> Int {
        return hashTable[hashTable[x & MASK] + y & MASK] + z
    }
}
