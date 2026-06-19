//
//  OnboardingTips.swift
//  CookingApp
//

import SwiftUI
import TipKit
import Combine

class OnboardingStateManager: ObservableObject {
    static let shared = OnboardingStateManager()
    @AppStorage("onboardingStep") var onboardingStep = 0
}

func updateOnboarding(to step: Int) {
    UserDefaults.standard.set(step, forKey: "onboardingStep")
    OnboardingStateManager.shared.onboardingStep = step
    
    ImportRecipeTip.step = step
    PasteLinkTip.step = step
    SaveRecipeTip.step = step
    StartCookTip.step = step
}

func syncOnboardingTips() {
    let step = UserDefaults.standard.integer(forKey: "onboardingStep")
    ImportRecipeTip.step = step
    PasteLinkTip.step = step
    SaveRecipeTip.step = step
    StartCookTip.step = step
}

// MARK: - Tip Structs

struct ImportRecipeTip: Tip {
    @Parameter static var step: Int = 0
    
    var title: Text { Text("Ambil Resep dari Web") }
    var message: Text? { Text("Tempel link resep pilihanmu di sini. Kami akan menyusun bahan dan langkah masaknya secara otomatis.") }
    var image: Image? { Image(systemName: "link.badge.plus") }
    
    var rules: [Rule] {
        #Rule(Self.$step) { $0 == 0 }
    }
}

struct PasteLinkTip: Tip {
    @Parameter static var step: Int = 0
    
    var title: Text { Text("Tempel Link") }
    var message: Text? { Text("Gunakan link resep yang sudah terisi otomatis di sini untuk mencoba fitur ekstrak resep.") }
    var image: Image? { Image(systemName: "doc.on.clipboard.fill") }
    
    var rules: [Rule] {
        #Rule(Self.$step) { $0 == 1 }
    }
}

struct SaveRecipeTip: Tip {
    @Parameter static var step: Int = 0
    
    var title: Text { Text("Siapkan Panduan Masak") }
    var message: Text? { Text("Simpan untuk menyusun resep ini menjadi langkah-langkah yang lebih mudah diikuti.") }
    var image: Image? { Image(systemName: "square.and.arrow.down.on.square.fill") }
    
    var rules: [Rule] {
        #Rule(Self.$step) { $0 == 2 }
    }
}

struct StartCookTip: Tip {
    @Parameter static var step: Int = 0
    
    var title: Text { Text("Mulai Simulasi Masak") }
    var message: Text? { Text("Mari lihat bagaimana aplikasi ini memandu instruksi resepmu tanpa perlu menyentuh layar.") }
    var image: Image? { Image(systemName: "flame.fill") }
    
    var actions: [Action] {
        [Tip.Action(id: "skip", title: "Lewati")]
    }
    
    var rules: [Rule] {
        #Rule(Self.$step) { $0 == 3 }
    }
}

extension View {
    @ViewBuilder
    func conditionalTip<T: Tip>(
        _ condition: Bool,
        tip: T,
        arrowEdge: Edge
    ) -> some View {
        if condition {
            self.popoverTip(tip, arrowEdge: arrowEdge)
                .tipViewStyle(ToolTipStyle())
        } else {
            self
        }
    }

    @ViewBuilder
    func conditionalTip(
        _ condition: Bool,
        tip: StartCookTip,
        arrowEdge: Edge,
        action: @escaping (Tip.Action) -> Void
    ) -> some View {
        if condition {
            self.popoverTip(tip, arrowEdge: arrowEdge, action: action)
                .tipViewStyle(ToolTipStyle())
        } else {
            self
        }
    }
}
