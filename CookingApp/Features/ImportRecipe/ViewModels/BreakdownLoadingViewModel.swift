//
//  BreakdownLoadingViewModel.swift
//  CookingApp
//

import SwiftUI
import Translation
import Combine

@MainActor
class BreakdownLoadingViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var errorMessage: String?
    
    // Translation Configs
    @Published var configIdToEn: TranslationSession.Configuration?
    @Published var configEnToId: TranslationSession.Configuration?
    
    // NLP State
    @Published var englishInstructions: [String]?
    @Published var intermediateBreakdownsEN: [[String]]?
    
    private let nlpService = RecipeNLPService()
    private var hasStarted = false
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func startBreakdown() {
        guard !hasStarted else { return }
        hasStarted = true
        
        print("▶️ [Breakdown] Memulai proses breakdown untuk resep: \"\(recipe.title)\"")
        
        self.configIdToEn = TranslationSession.Configuration(
            source: Locale.Language(identifier: "id-ID"),
            target: Locale.Language(identifier: "en-US")
        )
    }
    
    func resetAndRetry() {
        self.errorMessage = nil
        self.hasStarted = false
        self.configIdToEn = nil
        self.configEnToId = nil
        
        // Slight delay to allow View to register nil config, then re-trigger
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startBreakdown()
        }
    }
    
    func translateToEnglish(session: TranslationSession) async {
        print("▶️ [Breakdown] Mulai proses terjemahan (ID -> EN) untuk \(recipe.instructions.count) instruksi...")
        do {
            var translated: [String] = []
            for instruction in recipe.instructions {
                let response = try await session.translate(instruction.text)
                translated.append(response.targetText)
            }
            
            self.englishInstructions = translated
            print("✅ [Breakdown] Berhasil menerjemahkan instruksi ke Bahasa Inggris.")
            
            Task {
                await processLanguageModel()
            }
        } catch {
            print("❌ [Breakdown] Gagal menerjemahkan (ID -> EN): \(error.localizedDescription)")
            self.errorMessage = "Gagal memproses terjemahan: \(error.localizedDescription)"
        }
    }
    
    private func processLanguageModel() async {
        guard let enTexts = englishInstructions else {
            print("⚠️ [Breakdown] processLanguageModel dipanggil tapi englishInstructions kosong!")
            return
        }
        
        print("▶️ [Breakdown] Memulai proses NLP Model untuk memecah langkah-langkah...")
        do {
            let breakdowns = try await nlpService.breakdownInstructions(englishInstructions: enTexts)
            
            await MainActor.run {
                self.intermediateBreakdownsEN = breakdowns
                print("✅ [Breakdown] NLP Model berhasil memecah instruksi menjadi \(breakdowns.count) grup.")
                
                self.configEnToId = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en-US"),
                    target: Locale.Language(identifier: "id-ID")
                )
            }
        } catch {
            print("❌ [Breakdown] Gagal memproses NLP Model: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Gagal memproses Language Model: \(error.localizedDescription)"
            }
        }
    }
    
    func translateToIndonesian(session: TranslationSession, onComplete: ((Recipe) -> Void)?) async {
        guard let breakdownsEN = intermediateBreakdownsEN else {
            print("⚠️ [Breakdown] translateToIndonesian dipanggil tapi intermediateBreakdownsEN kosong!")
            return
        }
        
        print("▶️ [Breakdown] Mulai proses terjemahan akhir (EN -> ID)...")
        do {
            print("\n=== 📝 HASIL AKHIR BREAKDOWN NLP ===")
            for i in 0..<recipe.instructions.count {
                let enSteps = breakdownsEN[i]
                var finalBreakdown: [Instruction] = []
                var sequence = 1
                
                print("\n🔸 Original Instruksi \(i+1): \(recipe.instructions[i].text)")
                
                for step in enSteps {
                    let response = try await session.translate(step)
                    var idText = response.targetText
                    
                    if idText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "memindahkan" ||
                       idText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "hapus" {
                        idText = "Angkat"
                    } else {
                        idText = idText.replacingOccurrences(of: "Memindahkan", with: "Angkat", options: .caseInsensitive)
                        idText = idText.replacingOccurrences(of: "Hapus", with: "Angkat", options: .caseInsensitive)
                    }
                    
                    idText = idText.prefix(1).capitalized + idText.dropFirst()
                    
                    finalBreakdown.append(Instruction(sequenceNumber: sequence, text: idText))
                    print("   ↳ Step \(sequence): \(idText)")
                    sequence += 1
                }
                
                recipe.instructions[i].breakdownInstruction = finalBreakdown
            }
            print("\n===================================\n")
            print("✅ [Breakdown] Seluruh proses Breakdown selesai dengan sukses!")
            
            onComplete?(recipe)
        } catch {
            print("❌ [Breakdown] Gagal memproses terjemahan (EN -> ID): \(error.localizedDescription)")
            self.errorMessage = "Gagal memproses terjemahan akhir: \(error.localizedDescription)"
        }
    }
}
