import MetalKit

class GameView: MTKView {
    let renderer: Renderer
    
    required init(coder: NSCoder) {
        Engine.Ignite()
        renderer = Renderer()
        
        super.init(coder: coder)
        
        self.device = Engine.Device
        self.clearColor = Preferences.ClearColor
        self.colorPixelFormat = Preferences.PixelFormat
        self.delegate = renderer
    }
}
