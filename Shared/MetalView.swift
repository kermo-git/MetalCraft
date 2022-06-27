import SwiftUI
import MetalKit

// https://gist.github.com/HugoNijmek/d5b983784cf4519c5b352f41a790c237

func getScreenSize(view: MTKView) -> Float2 {
    return Float2(Float(view.bounds.width), Float(view.bounds.height))
}

var _screenSize: Float2 = Float2(0, 0)
var _aspectRatio: Float {
    _screenSize.x / _screenSize.y
}

struct MetalView {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeMTKView(_ context: MetalView.Context) -> MTKView {
        let mtkView = MTKView()
        
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        
        mtkView.device = Engine.Device
        mtkView.clearColor = Preferences.ClearColor
        mtkView.colorPixelFormat = Preferences.PixelFormat
        mtkView.depthStencilPixelFormat = Preferences.DepthPixelFormat
        
        return mtkView
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var worldRenderer = WorldRenderer()
        var parent: MetalView

        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            _screenSize = getScreenSize(view: view)
            worldRenderer.updateAspectRatio(aspectRatio: _aspectRatio)
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
            Player.update(deltaTime: deltaTime)
            WorldState.update(deltaTime: deltaTime)
            worldRenderer.update(deltaTime: deltaTime)
            
            worldRenderer.render(encoder!)
            
            encoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

#if os(macOS)
extension MetalView : NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {

    }
}
#endif

#if os(iOS)
extension MetalView : UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateUIView(_ nsView: MTKView, context: Context) {

    }
}
#endif



