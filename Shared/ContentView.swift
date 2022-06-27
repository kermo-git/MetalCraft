import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            #if os(macOS)
            .background(KeyboardAndMouseHandler())
            #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MetalView()
                .previewInterfaceOrientation(.landscapeRight)
        }
    }
}
