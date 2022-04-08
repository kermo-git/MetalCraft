import Metal

enum VertexShaderType {
    case Basic
}

enum FragmentShaderType {
    case Basic
}

class ShaderLibrary {
    static let DefaultLibrary: MTLLibrary = Engine.Device.makeDefaultLibrary()!
    
    private static var vertexShaders: [VertexShaderType: Shader] = [:]
    private static var fragmentShaders: [FragmentShaderType: Shader] = [:]
    
    static func Initialize() {
        vertexShaders.updateValue(
            BasicVertexShader(),
            forKey: .Basic)
        
        fragmentShaders.updateValue(
            BasicFragmentShader(),
            forKey: .Basic)
    }
    
    static func Vertex(_ type: VertexShaderType) -> MTLFunction {
        return vertexShaders[type]!.function
    }
    
    static func Fragment(_ type: FragmentShaderType) -> MTLFunction {
        return fragmentShaders[type]!.function
    }
}

protocol Shader {
    var label: String {get}
    var functionName: String {get}
    var function: MTLFunction! {get}
}

struct BasicVertexShader: Shader {
    var label: String = "Basic Vertex Shader"
    var functionName: String = "basic_vertex_shader"
    var function: MTLFunction!
    
    init() {
        function = ShaderLibrary.DefaultLibrary.makeFunction(name: functionName)
        function?.label = label
    }
}

struct BasicFragmentShader: Shader {
    var label: String = "Basic Fragment Shader"
    var functionName: String = "basic_fragment_shader"
    var function: MTLFunction!
    
    init() {
        function = ShaderLibrary.DefaultLibrary.makeFunction(name: functionName)
        function?.label = label
    }
}
