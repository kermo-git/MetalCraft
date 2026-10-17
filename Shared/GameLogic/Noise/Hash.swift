import simd

// https://www.shadertoy.com/view/XlGcRh
// https://www.jcgt.org/published/0009/03/02/

func hash2D_raw(_ seed: UInt32, _ key: Int2) -> UInt32 {
    let ukey = unsafeBitCast(key, to: UInt2.self)
    let v: UInt2 = ukey &+ seed &* 0x9E3779B9
    
    var h: UInt2 = v &* 1664525 &+ 1013904223
    h.x &+= h.y &* 1664525
    h.y &+= h.x &* 1664525
    h ^= UInt2(h.x >> 16, h.y >> 16)
    h.x &+= h.y &* 1664525
    
    return h.x ^ h.x >> 16
}

func hash3D_raw(_ seed: UInt32, _ key: Int3) -> UInt32 {
    let ukey = unsafeBitCast(key, to: UInt3.self)
    let v = ukey &+ seed &* 0x9E3779B9
    
    var h = v &* 1664525 &+ 1013904223
    h.x &+= h.y &* h.z
    h.y &+= h.z &* h.x
    h.z &+= h.x &* h.y
    h ^= UInt3(h.x >> 16, h.y >> 16, h.z >> 16)
    
    return h.x &+ h.y &* h.z
}

func hash2D(_ seed: UInt32, _ key: Int2, _ mask: UInt32 = 255) -> Int {
    return Int(hash2D_raw(seed, key) & mask)
}

func hash3D(_ seed: UInt32, _ key: Int3, _ mask: UInt32 = 255) -> Int {
    return Int(hash3D_raw(seed, key) & mask)
}
