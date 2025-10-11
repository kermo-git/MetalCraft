import SwiftUI

struct PositionLabel: View {
    @EnvironmentObject var scene: WorldRenderer
    
    func getPositionLabel() -> String {
        let pos = scene.cameraBlockPos
        return "\(pos.x), \(pos.y), \(pos.z)"
    }
    
    var body: some View {
        Text(getPositionLabel())
            .font(.title2)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundColor(Color.white)
    }
}

#Preview {
    ZStack {
        Color.green.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        
        PositionLabel()
            .environmentObject(
                WorldRenderer(generator: GameWorld(),
                           cameraPos: Float3(0, 70, 0))
            )
    }
}
