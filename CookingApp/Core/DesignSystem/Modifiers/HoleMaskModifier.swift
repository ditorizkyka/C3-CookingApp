import SwiftUI

extension View {
    /// Melacak frame dari view ini di dalam ruang koordinat (coordinate space) tertentu.
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
    
    /// Melacak frame global dari view ini dan menyimpannya ke dalam binding.
    /// Sangat berguna untuk mendapatkan frame target yang akan dilubangi oleh HoleMask.
    func trackGlobalFrame(_ frame: Binding<CGRect>) -> some View {
        self.trackFrame(in: .global, frame)
    }
    
    /// Menambahkan overlay gelap (masking) ke seluruh layar, 
    /// namun memberikan efek "lubang" transparan (eoFill) tepat di atas frame yang diberikan.
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
