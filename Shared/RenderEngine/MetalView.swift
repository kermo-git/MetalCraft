import SwiftUI
import MetalKit

// https://gist.github.com/HugoNijmek/d5b983784cf4519c5b352f41a790c237

struct MetalView {
    let renderer: any Renderer

    @MainActor func makeMTKView(_ context: MetalView.Context) -> MTKView {
        let mtkView = MTKView()
        
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        
        mtkView.device = renderer.engine.device
        mtkView.clearColor = renderer.clearColor
        mtkView.colorPixelFormat = pixelFormat
        mtkView.depthStencilPixelFormat = depthPixelFormat
        
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
        
        @MainActor func getScreenSize(view: MTKView) -> Float2 {
            return Float2(Float(view.bounds.width), Float(view.bounds.height))
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            let screenSize = getScreenSize(view: view)
            parent.renderer.setAspectRatio(screenSize.x / screenSize.y)
        }
        
        func draw(in view: MTKView) {
            guard
                let drawable = view.currentDrawable,
                let renderPassDescriptor = view.currentRenderPassDescriptor
            else {
                return
            }
            let deltaTime = 1 / Float(view.preferredFramesPerSecond)
            
            if let commandBuffer = parent.renderer.engine.commandQueue.makeCommandBuffer(),
               let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                parent.renderer.update(deltaTime: deltaTime)
                parent.renderer.render(encoder)
                encoder.endEncoding()
                commandBuffer.present(drawable)
                commandBuffer.commit()
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

#Preview {
    MetalView(renderer: ExampleRenderer())
}
