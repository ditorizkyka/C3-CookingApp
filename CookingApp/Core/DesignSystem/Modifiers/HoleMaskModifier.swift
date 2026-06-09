import SwiftUI

extension View {
    func trackFrame(in coordinateSpace: CoordinateSpace = .global, _ frame: Binding<CGRect>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        frame.wrappedValue = geo.frame(in: coordinateSpace)
                    }
                    .onChange(of: geo.frame(in: coordinateSpace)) { _, newFrame in
                        frame.wrappedValue = newFrame
                    }
            }
        )
    }
    
    func trackGlobalFrame(_ frame: Binding<CGRect>) -> some View {
        self.trackFrame(in: .global, frame)
    }
    
    func holeMaskOverlay(isActive: Binding<Bool>, holeFrame: CGRect, cornerRadius: CGFloat = 16, opacity: Double = 0.6) -> some View {
        self.modifier(HoleMaskModifier(isActive: isActive, holeFrame: holeFrame, cornerRadius: cornerRadius, maskOpacity: opacity))
    }
}

struct HoleMaskModifier: ViewModifier {
    @Binding var isActive: Bool
    var holeFrame: CGRect
    var cornerRadius: CGFloat
    var maskOpacity: Double

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { geo in
                        Path { path in
                            path.addRect(geo.frame(in: .local))
                            if holeFrame != .zero {
                                path.addRoundedRect(in: holeFrame, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
                            }
                        }
                        .fill(Color.black.opacity(maskOpacity), style: FillStyle(eoFill: true))
                    }
                    .ignoresSafeArea()
                }
            }
    }
}
