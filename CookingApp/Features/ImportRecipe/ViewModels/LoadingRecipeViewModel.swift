import SwiftUI
import Translation
import Combine

@MainActor
class LoadingRecipeViewModel: ObservableObject {
    @Published var scrapedRecipe: Recipe?
    @Published var errorMessage: String?
    @Published var navigateToDetail = false
    
    // Translation Configs
    @Published var configIdToEn: TranslationSession.Configuration?
    @Published var configEnToId: TranslationSession.Configuration?
    
    // NLP State
    @Published var englishInstructions: [String]?
    @Published var intermediateBreakdownsEN: [[String]]?
    
    // Dependencies
    private let scraperService = CookpadScraperService.shared
    private let nlpService = RecipeNLPService()
    
    func startScraping(url: String, onError: ((String) -> Void)?) {
        Task {
            do {
                let result = try await scraperService.scrape(urlString: url)
                self.scrapedRecipe = result
                // Trigger NLP Translation (ID -> EN)
                self.configIdToEn = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "id-ID"),
                    target: Locale.Language(identifier: "en-US")
                )
            } catch let error as ScraperError {
                self.errorMessage = error.errorDescription
                onError?(error.errorDescription ?? "Unknown error")
            } catch {
                self.errorMessage = error.localizedDescription
                onError?(error.localizedDescription)
            }
        }
    }
    
    func translateToEnglish(session: TranslationSession) async {
        guard let recipe = scrapedRecipe else { return }
        do {
            var translated: [String] = []
            for instruction in recipe.instructions {
                let response = try await session.translate(instruction.text)
                translated.append(response.targetText)
            }
            
            self.englishInstructions = translated
            
            Task {
                await processLanguageModel()
            }
        } catch {
            self.errorMessage = "Gagal memproses terjemahan: \(error.localizedDescription)"
        }
    }
    
    private func processLanguageModel() async {
        guard let enTexts = englishInstructions else { return }
        
        do {
            let breakdowns = try await nlpService.breakdownInstructions(englishInstructions: enTexts)
            
            await MainActor.run {
                self.intermediateBreakdownsEN = breakdowns
                // Trigger terjemahan kembali (EN -> ID)
                self.configEnToId = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en-US"),
                    target: Locale.Language(identifier: "id-ID")
                )
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Gagal memproses Language Model: \(error.localizedDescription)"
            }
        }
    }
    
    func translateToIndonesian(session: TranslationSession, onComplete: ((Recipe) -> Void)?) async {
        guard let recipe = scrapedRecipe, let breakdownsEN = intermediateBreakdownsEN else { return }
        do {
            print("\n=== HASIL BREAKDOWN NLP ===")
            for i in 0..<recipe.instructions.count {
                let enSteps = breakdownsEN[i]
                var finalBreakdown: [Instruction] = []
                var sequence = 1
                
                print("\nOriginal Instruksi \(i+1): \(recipe.instructions[i].text)")
                
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
                    print("  -> Step \(sequence): \(idText)")
                    sequence += 1
                }
                
                recipe.instructions[i].breakdownInstruction = finalBreakdown
            }
            print("\n===========================\n")
            
            onComplete?(recipe)
            self.navigateToDetail = true
        } catch {
            self.errorMessage = "Gagal memproses terjemahan akhir: \(error.localizedDescription)"
        }
    }
}
