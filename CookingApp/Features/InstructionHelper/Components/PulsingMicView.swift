import SwiftUI

struct PulsingMicView: View {
    var audioLevel: Float = 0.0
    var isListening: Bool = false
    
    @State private var idlePulse: CGFloat = 0.6
    
    private var effectiveScale: CGFloat {
        let audioScale = CGFloat(audioLevel) * 0.4
        return idlePulse + audioScale
    }
    
    var body: some View {
        Image(systemName: isListening ? "microphone.fill" : "speaker.wave.2.fill")
            .font(Font.title)
            .foregroundStyle(.white)
            .frame(width: 140, height: 140)
            .background(
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 237/255, green: 255/255, blue: 189/255),
                                    Color(red: 237/255, green: 255/255, blue: 189/255).opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 140
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(effectiveScale)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 213/255, green: 243/255, blue: 131/255),
                                    Color(red: 213/255, green: 243/255, blue: 131/255).opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(effectiveScale)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 189/255, green: 223/255, blue: 96/255),
                                    Color(red: 189/255, green: 223/255, blue: 96/255).opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            ))
                        .frame(width: 80, height: 80)
                        .scaleEffect(effectiveScale * 0.95)
                     
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0/255, green: 72/255, blue: 32/255),
                                    Color(red: 0/255, green: 72/255, blue: 32/255).opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(effectiveScale * 0.9)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            )
            .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.7), value: audioLevel)
            .animation(.easeInOut(duration: 0.3), value: isListening)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    idlePulse = 0.85
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PulsingMicView(audioLevel: 0.8, isListening: true)
    }
}
