import SwiftUI
import MetalKit

// https://gist.github.com/HugoNijmek/d5b983784cf4519c5b352f41a790c237

struct MetalView {
    let scene: GameScene

    func makeMTKView(_ context: MetalView.Context) -> MTKView {
        let mtkView = MTKView()
        
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        
        mtkView.device = Engine.device
        mtkView.clearColor = scene.clearColor
        mtkView.colorPixelFormat = Engine.pixelFormat
        mtkView.depthStencilPixelFormat = Engine.depthPixelFormat
        
        return mtkView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        let parent: MetalView

        init(parent: MetalView) {
            self.parent = parent
            super.init()
        }
        
        func getScreenSize(view: MTKView) -> Float2 {
            return Float2(Float(view.bounds.width), Float(view.bounds.height))
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            let screenSize = getScreenSize(view: view)
            parent.scene.setAspectRatio(screenSize.x / screenSize.y)
        }
        
        func draw(in view: MTKView) {
            guard
                let drawable = view.currentDrawable,
                let renderPassDescriptor = view.currentRenderPassDescriptor
            else {
                return
            }
            let deltaTime = 1 / Float(view.preferredFramesPerSecond)
            
            if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
               let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                encoder.setDepthStencilState(Engine.depthStencil)
                Task {
                    await parent.scene.update(deltaTime: deltaTime)
                    await parent.scene.render(encoder)
                    
                    encoder.endEncoding()
                    commandBuffer.present(drawable)
                    commandBuffer.commit()
                }
            }
        }
    }
}

#if os(macOS)
extension MetalView : NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}
#endif

#if os(iOS)
extension MetalView : UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateUIView(_ nsView: MTKView, context: Context) {}
}
#endif
