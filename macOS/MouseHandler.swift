import SwiftUI

// https://stackoverflow.com/questions/61153562/how-to-detect-keyboard-events-in-swiftui-on-macos

struct MouseHandler: NSViewRepresentable {
    let onMouseMove: (Float, Float) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = HandlerView()
        view.setParent(parent: self)
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    class HandlerView: NSView {
        var parent: MouseHandler!
        
        func setParent(parent: MouseHandler) {
            self.parent = parent
        }
        
        override var acceptsFirstResponder: Bool { return true }
        
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
            self.parent.onMouseMove(Float(event.deltaX), Float(event.deltaY))
        }
    }
}
