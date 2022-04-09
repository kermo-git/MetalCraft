import MetalKit

class GameView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        Engine.Ignite()
        
        self.renderer = Renderer(view: self)
        self.device = Engine.Device
        self.clearColor = Preferences.ClearColor
        self.colorPixelFormat = Preferences.PixelFormat
        self.depthStencilPixelFormat = Preferences.DepthPixelFormat
        self.delegate = renderer
    }
    
    override var acceptsFirstResponder: Bool { return true }
}

// Keyboard input
extension GameView {
    override func keyDown(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, true)
    }
    
    override func keyUp(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, false)
    }
    
    override func flagsChanged(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        Keyboard.setKeyPressed((KeyCode.SHIFT).rawValue, flags.contains(.shift))
        Keyboard.setKeyPressed((KeyCode.COMMAND).rawValue, flags.contains(.command))
    }
}

// Mouse clicks
extension GameView {
    override func mouseDown(with event: NSEvent) {
        Mouse.leftPressed = true
    }
    
    override func mouseUp(with event: NSEvent) {
        Mouse.leftPressed = false
    }
    
    override func rightMouseDown(with event: NSEvent) {
        Mouse.rightPressed = true
    }
    
    override func rightMouseUp(with event: NSEvent) {
        Mouse.rightPressed = false
    }
}

// Mouse movement
extension GameView {
    override func mouseMoved(with event: NSEvent) {
        handleMousePositionChange(event: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        handleMousePositionChange(event: event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        handleMousePositionChange(event: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        Mouse.scroll(deltaY: Float(event.deltaY))
    }
    
    override func updateTrackingAreas() {
        let area = NSTrackingArea(rect: self.bounds,
                                  options: [NSTrackingArea.Options.activeAlways,
                                            NSTrackingArea.Options.mouseMoved,
                                            NSTrackingArea.Options.enabledDuringMouseDrag],
                                  owner: self,
                                  userInfo: nil)
        self.addTrackingArea(area)
    }
    
    private func handleMousePositionChange(event: NSEvent) {
        let position = Float2(
            Float(event.locationInWindow.x),
            Float(event.locationInWindow.y)
        )
        let positionDelta = Float2(
            Float(event.deltaX),
            Float(event.deltaY)
        )
        Mouse.changePosition(newPosition: position, delta: positionDelta)
    }
}
