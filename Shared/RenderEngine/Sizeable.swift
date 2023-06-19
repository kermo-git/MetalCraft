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
