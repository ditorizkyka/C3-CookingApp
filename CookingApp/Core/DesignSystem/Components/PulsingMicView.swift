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
                        .fill(Color(red: 213/255, green: 243/255, blue: 131/255)) // #D5F383
                        .frame(width: 100, height: 100)
                        .scaleEffect(isPulsing ? 1.0 : 0.5)
                        .opacity(isPulsing ? 0.5 : 1.0)
                    
                    Circle()
                        .fill(Color(red: 189/255, green: 223/255, blue: 96/255)) // #BDDF60
                        .frame(width: 75, height: 75)
                        .scaleEffect(isPulsing ? 1.0 : 0.55)
                        .opacity(isPulsing ? 0.8 : 1.0)
                    
                    Circle()
                        .fill(Color(red: 0/255, green: 72/255, blue: 32/255)) // #004820
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
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
