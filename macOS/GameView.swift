import SwiftUI

struct GameView: View {
    let renderer: Renderer
    
    var body: some View {
        ZStack {
            MetalView(renderer: renderer)
                .background(KeyboardAndMouseHandler())
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(renderer: ExampleRenderer())
    }
}
