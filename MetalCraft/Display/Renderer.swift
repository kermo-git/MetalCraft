import MetalKit

func getScreenSize(view: MTKView) -> Float2 {
    return Float2(Float(view.bounds.width), Float(view.bounds.height))
}

class Renderer: NSObject {
    var sceneRenderer = WorldRenderer()
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
        sceneRenderer.updateAspectRatio(aspectRatio: Renderer.aspectRatio)
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
        
        sceneRenderer.update(deltaTime: 1 / Float(view.preferredFramesPerSecond))
        sceneRenderer.render(encoder!)
        
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
