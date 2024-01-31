import SwiftUI

struct GameButton: View {
    let systemName: String
    let onTouchStart: () -> ()
    let onTouchEnd: () -> ()
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.white.opacity(0.7))
                .padding(10)
                .background(.white.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({
                    _ in onTouchStart()
                })
                .onEnded({
                    _ in onTouchEnd()
                })
        )
    }
}


#Preview {
    ZStack {
        Color.green.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        GameButton(systemName: "arrowshape.left.fill",
                   onTouchStart: { print("Button pressed down") },
                   onTouchEnd: { print("Button released") })
    }
}
