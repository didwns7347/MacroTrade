import SwiftUI

struct FloatingButton: View {
    var body: some View {
        Image(systemName: "sparkle")
            .font(.title.weight(.semibold))
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(radius: 4, x: 0, y: 4)
    }
}

#Preview {
    FloatingButton()
}