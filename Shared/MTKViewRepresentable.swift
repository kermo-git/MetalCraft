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

let camera = FlyingCamera(startPos: Float3(0, 60, 0))
let worldState = ChunkLoader(cameraStartPos: camera.position, generator: generateChunk)
let worldRenderer = WorldRenderer(worldState: worldState, camera: camera)

struct MTKViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeMTKView(_ context: MTKViewRepresentable.Context) -> MTKView {
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
        var parent: MTKViewRepresentable

        init(_ parent: MTKViewRepresentable) {
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
            worldRenderer.update(deltaTime: deltaTime)
            worldRenderer.render(encoder!)
            
            encoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}
