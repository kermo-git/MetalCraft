import SwiftUI
import MetalKit

extension MTKViewRepresentable : NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {

    }
}

struct MetalView: View {
    var body: some View {
        MTKViewRepresentable()
            .background(KeyboardAndMouseHandler())
    }
}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MTKViewRepresentable()
                .previewInterfaceOrientation(.landscapeRight)
        }
    }
}
