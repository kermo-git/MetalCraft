import simd

typealias Int2 = SIMD2<Int32>
typealias UInt2 = SIMD2<UInt32>
typealias Int3 = SIMD3<Int32>
typealias UInt3 = SIMD3<UInt32>
typealias Half2 = SIMD2<Float16>
typealias Half3 = SIMD3<Float16>
typealias Half4 = SIMD4<Float16>
typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>
typealias Float4x4 = simd_float4x4
typealias Double2 = SIMD2<Double>
typealias Double3 = SIMD3<Double>

protocol Sizeable {
    static func memorySize() -> Int
}

extension Sizeable {
    static func memorySize() -> Int {
        return MemoryLayout<Self>.stride
    }
}

extension Array where Element: Sizeable {
    func memorySize() -> Int {
        return Element.memorySize() * count
    }
}

extension UInt16: Sizeable {}
extension Float2: Sizeable {}
extension Float3: Sizeable {}
extension Float4: Sizeable {}
extension Float4x4: Sizeable {}

extension Float3 {
    func toString() -> String {
        return "\(x), \(y), \(z)"
    }
}
