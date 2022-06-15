import MetalKit

func getScreenSize(view: MTKView) -> Float2 {
    return Float2(Float(view.bounds.width), Float(view.bounds.height))
}

class Renderer: NSObject {
    var worldRenderer = WorldRenderer() // TestWorldRenderer(faces: buildTestWorld())
    static var screenSize: Float2 = Float2(0, 0)
    static var aspectRatio: Float {
        screenSize.x / screenSize.y
    }
    
    init(view: MTKView) {
        Renderer.screenSize = getScreenSize(view: view)
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Renderer.screenSize = getScreenSize(view: view)
        worldRenderer.updateAspectRatio(aspectRatio: Renderer.aspectRatio)
    }
    
    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor
        else {
            return
        }
        
        let commandBuffer = Engine.CommandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        GameState.update(deltaTime: deltaTime)
        worldRenderer.update(deltaTime: deltaTime)
        worldRenderer.render(encoder!)
        
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
