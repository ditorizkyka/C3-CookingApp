import SwiftUI

struct PulsingMicView: View {
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: "microphone.fill")
            .font(Font.title)
            .foregroundStyle(.white)
            .background(
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary?.opacity(0.1) ?? Color.green.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isPulsing ? 1.0 : 0.5)
                    
                    Circle()
                        .fill(Color.brandPrimary?.opacity(0.3) ?? Color.green.opacity(0.3))
                        .frame(width: 75, height: 75)
                        .scaleEffect(isPulsing ? 1.0 : 0.55)
                    
                    Circle()
                        .fill(Color.brandPrimary ?? Color.green)
                        .frame(width: 50, height: 50)
                }
            )
        .padding(.vertical, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing.toggle()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PulsingMicView()
    }
}
