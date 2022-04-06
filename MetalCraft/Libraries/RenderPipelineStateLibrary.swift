import Metal

enum RenderPipelineStateType {
    case Basic
}

class RenderPipelineStateLibrary {
    private static var descriptors: [RenderPipelineStateType: RenderPipelineState] = [:]
    
    static func Initialize() {
        descriptors.updateValue(BasicRenderPipelineState(), forKey: .Basic)
    }
    
    static func get(_ type: RenderPipelineStateType) -> MTLRenderPipelineState {
        return descriptors[type]!.state
    }
}

protocol RenderPipelineState {
    var name: String {get}
    var state: MTLRenderPipelineState {get}
}

class BasicRenderPipelineState: RenderPipelineState {
    var name: String = "Basic Render Pipeline State"
    
    var state: MTLRenderPipelineState {
        var result: MTLRenderPipelineState!
        do {
            result = try Engine.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.get(.Basic))
        } catch {
            print(error.localizedDescription)
        }
        return result
    }
}
