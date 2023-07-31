import SwiftUI

// https://stackoverflow.com/questions/61153562/how-to-detect-keyboard-events-in-swiftui-on-macos

struct KeyboardAndMouseHandler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = HandlerView()
        
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    class HandlerView: NSView {
        override var acceptsFirstResponder: Bool { return true }
        
        // Keyboard input
        
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
        
        // Mouse clicks
        
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
        
        // Mouse movement
        
        override func mouseMoved(with event: NSEvent) {
            handleMouseMove(event: event)
        }
        
        override func mouseDragged(with event: NSEvent) {
            handleMouseMove(event: event)
        }
        
        override func rightMouseDragged(with event: NSEvent) {
            handleMouseMove(event: event)
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
        
        private func handleMouseMove(event: NSEvent) {
            Mouse.move(Float(event.deltaX), Float(event.deltaY))
        }
    }
}
