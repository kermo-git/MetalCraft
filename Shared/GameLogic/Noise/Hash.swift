// https://github.com/chen3feng/toft/blob/master/hash/murmur/MurmurHash2_64.cpp

private let m: UInt64 = 0xc6a4a7935bd1e995
private let seed_scramble_2D: UInt64 = 16 &* m
private let seed_scramble_3D: UInt64 = 24 &* m
private let r = 47

private func hash2D_raw(_ seed: UInt64, _ key: Int2) -> UInt64 {
    var h = seed ^ seed_scramble_2D
    var k = UInt64(bitPattern: Int64(key.x))
    
    k &*= m
    k ^= k >> r
    k &*= m

    h ^= k
    h &*= m
    
    k = UInt64(bitPattern: Int64(key.y))
    
    k &*= m
    k ^= k >> r
    k &*= m

    h ^= k
    h &*= m
    
    h ^= h >> r
    h &*= m;
    h ^= h >> r

    return h
}

private func hash3D_raw(_ seed: UInt64, _ key: Int3) -> UInt64 {
    var h = seed ^ seed_scramble_3D
    var k = UInt64(bitPattern: Int64(key.x))
    
    k &*= m
    k ^= k >> r
    k &*= m

    h ^= k
    h &*= m
    
    k = UInt64(bitPattern: Int64(key.y))
    
    k &*= m
    k ^= k >> r
    k &*= m

    h ^= k
    h &*= m
    
    k = UInt64(bitPattern: Int64(key.z))
    
    k &*= m
    k ^= k >> r
    k &*= m

    h ^= k
    h &*= m
    
    h ^= h >> r
    h &*= m;
    h ^= h >> r

    return h
}

func hash2D(_ seed: UInt64, _ key: Int2, _ mask: UInt64 = 255) -> Int {
    return Int(hash2D_raw(seed, key) & mask)
}

func hash3D(_ seed: UInt64, _ key: Int3, _ mask: UInt64 = 255) -> Int {
    return Int(hash3D_raw(seed, key) & mask)
}
