import simd

private let simplex2D_skew: Float = 0.5 * (sqrt(3.0)-1.0)
private let simplex2D_unskew: Float = (3.0 - sqrt(3.0))/6.0
private let simplex_2D_corner_2_unskew = -1.0 + 2.0 * simplex2D_unskew

private let simplex3D_skew: Float = 1.0 / 3.0
private let simplex3D_unskew: Float = 1.0 / 6.0
private let simplex_3D_corner_2_unskew = 2.0 * simplex3D_unskew;
private let simplex_3D_corner_3_unskew = -1.0 + 3.0 * simplex3D_unskew;

private let MASK = 255

class SimplexNoise: NoiseGenerator {
    private var hashTable: [Int] = []
    private var grad2D: [Float2] = []
    
    init() {
        for i in 0...MASK {
            hashTable.append(i)
        }
        hashTable.shuffle()
        
        for i in 0...MASK {
            hashTable.append(hashTable[i])
        }
        let n_grad2D = 8
        for i in 0..<n_grad2D {
            let frac = Float(i)/Float(n_grad2D)
            let phi = 2 * Float.pi * frac
            grad2D.append(
                Float2(cos(phi), sin(phi))
            )
        }
    }
    
    func signedNoise2D(_ x: Float, _ y: Float) -> Float {
        var s = (x + y) * simplex2D_skew
        let fi = floor(x + s)
        let fj = floor(y + s)
        
        s = (fi + fj) * simplex2D_unskew
        let u0 = x - fi + s
        let v0 = y - fj + s
        
        let i = Int(fi) & MASK
        let j = Int(fj)
        
        var i1: Int, j1: Int
        
        if (u0 >= v0) {
            i1 = 1; j1 = 0
        } else {
            i1 = 0; j1 = 1
        }
        let u1 = u0 - Float(i1) + simplex2D_unskew
        let v1 = v0 - Float(j1) + simplex2D_unskew
        
        let u2 = u0 + simplex_2D_corner_2_unskew
        let v2 = v0 + simplex_2D_corner_2_unskew
        
        var n0: Float = 0.0
        var t = 0.5 - (u0 * u0 + v0 * v0)
        if (t >= 0) {
            let h = (hashTable[i] + j) & 7
            let grad = grad2D[h]
            n0 = t * t * t * t * (u0 * grad.x + v0 * grad.y)
        }
        
        var n1: Float = 0.0
        t = 0.5 - (u1 * u1 + v1 * v1)
        if (t >= 0) {
            let h = (hashTable[i + i1] + j + j1) & 7
            let grad = grad2D[h]
            n1 = t * t * t * t * (u1 * grad.x + v1 * grad.y)
        }
        
        var n2: Float = 0.0
        t = 0.5 - (u2 * u2 + v2 * v2)
        if (t >= 0) {
            let h = (hashTable[i + 1] + j + 1) & 7
            let grad = grad2D[h]
            n2 = t * t * t * t * (u2 * grad.x + v2 * grad.y)
        }
        return 70 * (n0 + n1 + n2)
    }
    
    func signedNoise3D(_ x: Float, _ y: Float, _ z: Float) -> Float {
        var s = (x + y + z) * simplex3D_skew;
        let fi = floor(x + s);
        let fj = floor(y + s);
        let fk = floor(z + s);
        
        s = (fi + fj + fk) * simplex3D_unskew;
        let u0 = x - fi + s;
        let v0 = y - fj + s;
        let w0 = z - fk + s;
        
        let i = Int(fi) & MASK;
        let j = Int(fj) & MASK;
        let k = Int(fk);
        
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
        let u1 = u0 - Float(i1) + simplex3D_unskew;
        let v1 = v0 - Float(j1) + simplex3D_unskew;
        let w1 = w0 - Float(k1) + simplex3D_unskew;
        
        let u2 = u0 - Float(i2) + simplex_3D_corner_2_unskew
        let v2 = v0 - Float(j2) + simplex_3D_corner_2_unskew
        let w2 = w0 - Float(k2) + simplex_3D_corner_2_unskew
        
        let u3 = u0 + simplex_3D_corner_3_unskew
        let v3 = v0 + simplex_3D_corner_3_unskew
        let w3 = w0 + simplex_3D_corner_3_unskew
        
        var n0: Float = 0.0
        var t = 0.6 - (u0 * u0 + v0 * v0 + w0 * w0)
        if (t >= 0) {
            let h = hash3D(i, j, k)
            n0 = t * t * t * t * grad3D(h, u0, v0, w0)
        }
        
        var n1: Float = 0.0
        t = 0.6 - (u1 * u1 + v1 * v1 + w1 * w1)
        if (t >= 0) {
            let h = hash3D(i + i1, j + j1, k + k1)
            n1 = t * t * t * t * grad3D(h, u1, v1, w1)
        }
        
        var n2: Float = 0.0
        t = 0.6 - (u2 * u2 + v2 * v2 + w2 * w2)
        if (t >= 0) {
            let h = hash3D(i + i2, j + j2, k + k2)
            n2 = t * t * t * t * grad3D(h, u2, v2, w2)
        }
        
        var n3: Float = 0.0
        t = 0.6 - (u3 * u3 + v3 * v3 + w3 * w3)
        if (t >= 0) {
            let h = hash3D(i + 1, j + 1, k + 1)
            n3 = t * t * t * t * grad3D(h, u3, v3, w3)
        }
        
        return 32 * (n0 + n1 + n2 + n3)
    }
    
    private func hash3D(_ x: Int, _ y: Int, _ z: Int) -> Int {
        return hashTable[hashTable[x] + y] + z
    }
}

private func grad3D(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
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
