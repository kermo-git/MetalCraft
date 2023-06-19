import SwiftUI
import MetalKit

extension MTKViewRepresentable : UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateUIView(_ nsView: MTKView, context: Context) {

    }
}

struct MetalView: View {
    var body: some View {
        MTKViewRepresentable()
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
