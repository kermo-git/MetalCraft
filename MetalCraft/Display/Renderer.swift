import MetalKit

class Renderer: NSObject {
    var gameObject: GameObject = GameObject(meshType: .Quad)
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO
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
        encoder?.setRenderPipelineState(RenderPipelineStateLibrary.get(.Basic))
        
        gameObject.update(deltaTime: 1 / Float(view.preferredFramesPerSecond))
        gameObject.render(encoder!)
        
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
