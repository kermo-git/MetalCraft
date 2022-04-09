import simd

typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>
typealias Float4x4 = simd_float4x4

protocol Sizeable {
    static func size() -> Int
    static func size(_ count: Int) -> Int
}

extension Sizeable {
    static func size() -> Int {
        return MemoryLayout<Self>.stride
    }
    static func size(_ count: Int) -> Int {
        return MemoryLayout<Self>.stride * count
    }
}

extension UInt16: Sizeable {}
extension Float2: Sizeable {}
extension Float3: Sizeable {}
extension Float4: Sizeable {}
extension Float4x4: Sizeable {}

struct Vertex: Sizeable {
    var position: Float3
    var color: Float4
}

struct ShaderConstants: Sizeable {
    var projectionViewModel: Float4x4 = matrix_identity_float4x4
}
