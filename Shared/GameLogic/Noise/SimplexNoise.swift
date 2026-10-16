import simd

private let simplex2D_skew: Float = 0.5 * (sqrt(3.0)-1.0)
private let simplex2D_unskew: Float = (3.0 - sqrt(3.0))/6.0
private let simplex_2D_corner_2_unskew = -1.0 + 2.0 * simplex2D_unskew

private let simplex3D_skew: Float = 1.0 / 3.0
private let simplex3D_unskew: Float = 1.0 / 6.0
private let simplex_3D_corner_2_unskew = 2.0 * simplex3D_unskew;
private let simplex_3D_corner_3_unskew = -1.0 + 3.0 * simplex3D_unskew;

private let grad2D: [Float2] = (0..<8).map {
    let frac = Float($0)/Float(8)
    let phi = 2 * Float.pi * frac
    return Float2(cos(phi), sin(phi))
}

func simplex2D(_ seed: UInt64, _ pos: Float2) -> Float {
    var s = (pos.x + pos.y) * simplex2D_skew
    let f_skew_c0 = floor(pos + s)
    
    s = (f_skew_c0.x + f_skew_c0.y) * simplex2D_unskew
    let c0 = pos - f_skew_c0 + s
    
    let skew_c0 = Int2(f_skew_c0)
    var skew_c0_c1: Int2
    
    if (c0.x >= c0.y) {
        skew_c0_c1 = Int2(1, 0)
    } else {
        skew_c0_c1 = Int2(0, 1)
    }
    let c1 = c0 - Float2(skew_c0_c1) + simplex2D_unskew
    let c2 = c0 + simplex_2D_corner_2_unskew
    
    var n0: Float = 0.0
    var t = 0.5 - dot(c0, c0)
    if (t >= 0) {
        let h = hash2D(seed, skew_c0, 7)
        let grad = grad2D[h]
        n0 = t * t * t * t * dot(c0, grad)
    }
    
    var n1: Float = 0.0
    t = 0.5 - dot(c1, c1)
    if (t >= 0) {
        let h = hash2D(seed, skew_c0 &+ skew_c0_c1, 7)
        let grad = grad2D[h]
        n1 = t * t * t * t * dot(c1, grad)
    }
    
    var n2: Float = 0.0
    t = 0.5 - dot(c2, c2)
    if (t >= 0) {
        let h = hash2D(seed, skew_c0 &+ 1, 7)
        let grad = grad2D[h]
        n2 = t * t * t * t * dot(c2, grad)
    }
    return 70 * (n0 + n1 + n2)
}

func simplex3D(_ seed: UInt64, _ pos: Float3) -> Float {
    var s = (pos.x + pos.y + pos.z) * simplex3D_skew
    let f_skew_c0 = floor(pos + s)
    
    s = (f_skew_c0.x + f_skew_c0.y + f_skew_c0.z) * simplex3D_unskew
    let c0 = pos - f_skew_c0 + s
    
    let skew_c0 = Int3(f_skew_c0)
    var skew_c0_c1, skew_c0_c2: Int3

    if (c0.x >= c0.y) {
        if (c0.y >= c0.z) {
            skew_c0_c1 = Int3(1, 0, 0)
            skew_c0_c2 = Int3(1, 1, 0)
        } else if (c0.z > c0.x) {
            skew_c0_c1 = Int3(0, 0, 1)
            skew_c0_c2 = Int3(1, 0, 1)
        } else {
            skew_c0_c1 = Int3(1, 0, 0)
            skew_c0_c2 = Int3(1, 0, 1)
        }
    } else {
        if (c0.z < c0.x) {
            skew_c0_c1 = Int3(0, 1, 0)
            skew_c0_c2 = Int3(1, 1, 0)
        } else if (c0.z > c0.y) {
            skew_c0_c1 = Int3(0, 0, 1)
            skew_c0_c2 = Int3(0, 1, 1)
        } else {
            skew_c0_c1 = Int3(0, 1, 0)
            skew_c0_c2 = Int3(0, 1, 1)
        }
    }
    let c1 = c0 - Float3(skew_c0_c1) + simplex3D_unskew
    let c2 = c0 - Float3(skew_c0_c2) + simplex_3D_corner_2_unskew
    let c3 = c0 + simplex_3D_corner_3_unskew
    
    var n0: Float = 0.0
    var t = 0.6 - dot(c0, c0)
    if (t >= 0) {
        let h = hash3D(seed, skew_c0, 15)
        n0 = t * t * t * t * grad3D(h, c0)
    }
    
    var n1: Float = 0.0
    t = 0.6 - dot(c1, c1)
    if (t >= 0) {
        let h = hash3D(seed, skew_c0 &+ skew_c0_c1, 15)
        n1 = t * t * t * t * grad3D(h, c1)
    }
    
    var n2: Float = 0.0
    t = 0.6 - dot(c2, c2)
    if (t >= 0) {
        let h = hash3D(seed, skew_c0 &+ skew_c0_c2, 15)
        n2 = t * t * t * t * grad3D(h, c2)
    }
    
    var n3: Float = 0.0
    t = 0.6 - dot(c3, c3)
    if (t >= 0) {
        let h = hash3D(seed, skew_c0 &+ 1, 15)
        n3 = t * t * t * t * grad3D(h, c3)
    }
    
    return 32 * (n0 + n1 + n2 + n3)
}

private func grad3D(_ hash: Int, _ corner: Float3) -> Float {
    let x = corner.x
    let y = corner.y
    let z = corner.z
    
    switch (hash) {
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
