import SwiftUI

struct PulsingMicView: View {
    var audioLevel: Float = 0.0
    var isListening: Bool = false
    var isSpeaking: Bool = false

    @State private var idlePulse: CGFloat = 0.6

    private var effectiveScale: CGFloat {
        let audioScale = CGFloat(audioLevel) * 0.4
        return idlePulse + audioScale
    }

    private var outerColor: Color {
        if isSpeaking { return Color(red: 255/255, green: 210/255, blue: 80/255)  } // kuning cerah
        return Color(red: 237/255, green: 255/255, blue: 189/255)                   // hijau muda
    }

    private var midColor: Color {
        if isSpeaking { return Color(red: 255/255, green: 204/255, blue: 33/255)  } // kuning brandSecondary #FFCC21
        return Color(red: 213/255, green: 243/255, blue: 131/255)                   // hijau ovalGreen-mid
    }

    private var innerColor: Color {
        if isSpeaking { return Color(red: 220/255, green: 140/255, blue: 0/255)   } // oranye emas
        return Color(red: 189/255, green: 223/255, blue: 96/255)                    // hijau ovalGreen
    }

    private var coreColor: Color {
        if isSpeaking { return Color(red: 120/255, green: 60/255, blue: 0/255)    } // coklat gelap
        return Color(red: 0/255, green: 72/255, blue: 32/255)                       // hijau brandPrimary
    }

    private var currentIcon: String {
        if isSpeaking  { return "speaker.wave.3.fill" }
        if isListening { return "microphone.fill" }
        return "microphone"
    }

    var body: some View {
        Image(systemName: currentIcon)
            .font(Font.title)
            .foregroundStyle(.white)
            .frame(width: 140, height: 140)
            .background(
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    outerColor,
                                    outerColor.opacity(0)
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
                                    midColor,
                                    midColor.opacity(0)
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
                                    innerColor,
                                    innerColor.opacity(0)
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
                                    coreColor,
                                    coreColor.opacity(0)
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
            .animation(.easeInOut(duration: 0.4), value: isListening)
            .animation(.easeInOut(duration: 0.4), value: isSpeaking)
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
        PulsingMicView(audioLevel: 0.8, isListening: true, isSpeaking: false)
    }
}
