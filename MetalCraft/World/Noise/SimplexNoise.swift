import simd

class SimplexNoise: NoiseGenerator {
    private let SIZE = 256
    private let MASK = 255
    
    private var hashTable: [Int] = []
    
    init() {
        for i in 0..<SIZE {
            hashTable.append(i)
        }
        hashTable.shuffle()
        
        for i in 0..<SIZE {
            hashTable.append(hashTable[i])
        }
    }
    
    private var i: Int = 0,
                j: Int = 0,
                k: Int = 0,
                u: Float = 0.0,
                v: Float = 0.0,
                w: Float = 0.0
    
    func signedNoise(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var s = (x + y + z)/3.0;
        i = Int(floor(x + s));
        j = Int(floor(y + s));
        k = Int(floor(z + s));
        
        s = Float(i + j + k) / 6.0;
        u = x - Float(i) + s;
        v = y - Float(j) + s;
        w = z - Float(k) + s;
        
        var i1: Int,
            j1: Int,
            k1: Int,
            i2: Int,
            j2: Int,
            k2: Int

        if (u > v) {
            if (v > w) {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 1; k2 = 0;
            } else if (w > u) {
                i1 = 0; j1 = 0; k1 = 1; i2 = 1; j2 = 0; k2 = 1;
            } else {
                i1 = 1; j1 = 0; k1 = 0; i2 = 1; j2 = 0; k2 = 1;
            }
        } else {
            if (w < u) {
                i1 = 0; j1 = 1; k1 = 0; i2 = 1; j2 = 1; k2 = 0;
            } else if (w > v) {
                i1 = 0; j1 = 0; k1 = 1; i2 = 0; j2 = 1; k2 = 1;
            } else {
                i1 = 0; j1 = 1; k1 = 0; i2 = 0; j2 = 1; k2 = 1;
            }
        }
        
        let n0 = influence(di: 0,  dj: 0,  dk: 0)
        let n1 = influence(di: i1, dj: j1, dk: k1)
        let n2 = influence(di: i2, dj: j2, dk: k2)
        let n3 = influence(di: 1,  dj: 1,  dk: 1)
        
        return 3 * (n0 + n1 + n2 + n3)
    }
    
    private func influence(di: Int, dj: Int, dk: Int) -> Float {
        let s = Float(di + dj + dk) / 6.0
        let x = u - Float(di) + s
        let y = v - Float(dj) + s
        let z = w - Float(dk) + s

        let t = 0.6 - (x * x + y * y + z * z)
        if (t < 0) {
            return 0
        }

        let h = hash(x: i + di, y: j + dj, z: k + dk)
        return 8 * t * t * t * t * grad(hash: h, x: x, y: y, z: z)
    }
    
    private func hash(x: Int, y: Int, z: Int) -> Int {
        return hashTable[hashTable[x & MASK] + y & MASK] + z
    }
    
    private func grad(hash: Int, x: Float, y: Float, z: Float) -> Float {
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
}
