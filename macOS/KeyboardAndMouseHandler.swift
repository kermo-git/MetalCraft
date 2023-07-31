import SwiftUI

// https://stackoverflow.com/questions/61153562/how-to-detect-keyboard-events-in-swiftui-on-macos

struct KeyboardAndMouseHandler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        HandlerView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    class HandlerView: NSView {
        override var acceptsFirstResponder: Bool { return true }
        
        // Keyboard input
        
        override func keyDown(with event: NSEvent) {
            Keyboard.setKeyPressed(event.keyCode, true)
            refreshInput()
        }
        
        override func keyUp(with event: NSEvent) {
            Keyboard.setKeyPressed(event.keyCode, false)
            refreshInput()
        }
        
        override func flagsChanged(with event: NSEvent) {
            Keyboard.toggleKey(event.keyCode)
            refreshInput()
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
        
        // Private functions
        
        private func refreshInput() {
            Input.moveForward = Keyboard.isKeyPressed(MOVE_FORWARD_KEY)
            Input.moveBackward = Keyboard.isKeyPressed(MOVE_BACKWARD_KEY)
            Input.moveLeft = Keyboard.isKeyPressed(MOVE_LEFT_KEY)
            Input.moveRight = Keyboard.isKeyPressed(MOVE_RIGHT_KEY)
            Input.flyUp = Keyboard.isKeyPressed(FLY_UP_KEY)
            Input.flyDown = Keyboard.isKeyPressed(FLY_DOWN_KEY)
        }
        
        private func handleMouseMove(event: NSEvent) {
            Input.rotateCamera(Float(event.deltaX), Float(event.deltaY))
        }
    }
}

class Keyboard {
    private static let KEY_COUNT = 256
    private static var keys: [Bool] = [Bool].init(repeating: false, count: KEY_COUNT)
    
    static func setKeyPressed(_ keyCode: UInt16, _ isPressed: Bool) {
        keys[Int(keyCode)] = isPressed
    }
    
    static func toggleKey(_ keyCode: UInt16) {
        keys[Int(keyCode)] = !keys[Int(keyCode)]
    }
    
    static func isKeyPressed(_ keyCode: KeyCode) -> Bool {
        return keys[Int(keyCode.rawValue)]
    }
    
    static func isKeyPressed(_ keyCodes: [KeyCode]) -> Bool {
        for code in keyCodes {
            if (keys[Int(code.rawValue)]) {
                return true
            }
        }
        return false
    }
}
