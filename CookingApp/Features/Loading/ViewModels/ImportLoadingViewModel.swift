import SwiftUI
import Combine
import Translation
import NaturalLanguage

@MainActor
class ImportLoadingViewModel: ObservableObject {
    enum LoadingState {
        case idle
        case extracting
        case translatingIDtoEN
        case breakingDown
        case translatingENtoID
        
        var message: String {
            switch self {
            case .idle: return ""
            case .extracting: return "Mengunduh resep dari website..."
            case .translatingIDtoEN: return "Membaca instruksi memasak..."
            case .breakingDown: return "Menganalisis langkah..."
            case .translatingENtoID: return "Menyusun resep akhir..."
            }
        }
    }
    
    @Published var state: LoadingState = .idle
    @Published var errorMessage: String?
    @Published var recipe: Recipe?
    
    // Translation Configs
    @Published var configIdToEn: TranslationSession.Configuration?
    @Published var configEnToId: TranslationSession.Configuration?
    
    // Internal State
    private var englishInstructions: [String]?
    private var englishIngredients: [String]?
    private var intermediateBreakdownsEN: [[String]]?
    private var activeTask: Task<Void, Never>?
    private var hasStarted = false
    private var sourceLanguageIsEnglish = false
    private var completionHandler: ((Recipe) -> Void)?
    
    // Dependencies
    private let scraperService = WebScraperService.shared
    private let nlpService = InstructionBreakdownService()
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe
    }
    
    func start(url: String?, onComplete: @escaping (Recipe) -> Void) {
        guard !hasStarted else { return }
        hasStarted = true
        errorMessage = nil
        self.completionHandler = onComplete
        
        activeTask = Task {
            do {
                if recipe != nil {
                    await MainActor.run {
                        self.processRecipeLanguage(recipe: self.recipe!)
                    }
                } else if let validUrl = url {
                    // 1. Scraping
                    await MainActor.run { self.state = .extracting }
                    let result = try await scraperService.scrape(urlString: validUrl)
                    if Task.isCancelled { return }
                    
                    await MainActor.run { 
                        self.recipe = result
                        self.processRecipeLanguage(recipe: result)
                    }
                }
            } catch let error as ScraperError {
                handleError(error.errorDescription ?? "Unknown error")
            } catch {
                handleError(error.localizedDescription)
            }
        }
    }
    
    private func processRecipeLanguage(recipe: Recipe) {
        let combinedText = recipe.instructions.map { $0.text }.joined(separator: " ")
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(combinedText)
        
        let rawLang = recognizer.dominantLanguage?.rawValue ?? "id"
        let detectedLanguage: String
        switch rawLang {
        case "id": detectedLanguage = "id-ID"
        case "en": detectedLanguage = "en-US"
        case "ja": detectedLanguage = "ja-JP"
        case "ko": detectedLanguage = "ko-KR"
        case "zh": detectedLanguage = "zh-CN"
        case "fr": detectedLanguage = "fr-FR"
        case "es": detectedLanguage = "es-ES"
        case "de": detectedLanguage = "de-DE"
        case "it": detectedLanguage = "it-IT"
        default: detectedLanguage = rawLang
        }
        
        if rawLang == "en" {
            self.sourceLanguageIsEnglish = true
            self.englishInstructions = recipe.instructions.map { $0.text }
            self.englishIngredients = self.extractIngredientNames()
            
            Task {
                await self.processLanguageModel()
            }
        } else {
            self.sourceLanguageIsEnglish = false
            self.state = .translatingIDtoEN
            self.configIdToEn = TranslationSession.Configuration(
                source: Locale.Language(identifier: detectedLanguage),
                target: Locale.Language(identifier: "en-US")
            )
        }
    }
    
    func translateToEnglish(session: TranslationSession) async {
        guard let recipe = recipe else { return }
        if Task.isCancelled { return }
        
        do {
            var translated: [String] = []
            for instruction in recipe.instructions {
                let response = try await session.translate(instruction.text)
                translated.append(response.targetText)
            }
            self.englishInstructions = translated
            
            let idIngredients = extractIngredientNames()
            var enIngredients: [String] = []
            for ingredient in idIngredients {
                let response = try await session.translate(ingredient)
                enIngredients.append(response.targetText)
            }
            self.englishIngredients = enIngredients
            
            if Task.isCancelled { return }
            await processLanguageModel()
        } catch {
            handleError("Gagal menerjemahkan ke bahasa Inggris: \(error.localizedDescription)")
        }
    }
    
    private func processLanguageModel() async {
        guard let enTexts = englishInstructions else { return }
        if Task.isCancelled { return }
        
        await MainActor.run { self.state = .breakingDown }
        
        do {
            let ingredientNames = englishIngredients ?? []
            let breakdowns = try await nlpService.breakdownInstructions(
                englishInstructions: enTexts,
                ingredients: ingredientNames
            )
            if Task.isCancelled { return }
            
            await MainActor.run {
                self.intermediateBreakdownsEN = breakdowns
                self.state = .translatingENtoID
                self.configEnToId = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en-US"),
                    target: Locale.Language(identifier: "id-ID")
                )
            }
        } catch {
            handleError("Gagal memproses AI Model: \(error.localizedDescription)")
        }
    }
    
    private func extractIngredientNames() -> [String] {
        guard let ingredients = recipe?.ingredients else { return [] }
        var names: [String] = []
        for ingredient in ingredients {
            if ingredient.isGroup, let subs = ingredient.groupIngredients {
                names.append(contentsOf: subs.map { "\($0.quantity) \($0.name)".trimmingCharacters(in: .whitespaces) })
            } else {
                names.append("\(ingredient.quantity) \(ingredient.name)".trimmingCharacters(in: .whitespaces))
            }
        }
        return names
    }
    

    func translateToIndonesian(session: TranslationSession) async {
        guard let breakdownsEN = intermediateBreakdownsEN, let recipe = recipe else { return }
        if Task.isCancelled { return }
        
        do {
            for i in 0..<recipe.instructions.count {
                let enSteps = breakdownsEN[i]
                var finalBreakdown: [Instruction] = []
                var sequence = 1
                
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
                    sequence += 1
                }
                
                recipe.instructions[i].breakdownInstruction = finalBreakdown
            }
            
            if Task.isCancelled { return }
            self.completionHandler?(recipe)
        } catch {
            handleError("Gagal menyusun terjemahan akhir: \(error.localizedDescription)")
        }
    }
    
    func cancel() {
        activeTask?.cancel()
        hasStarted = false
    }
    
    func resetAndRetry(url: String?, onComplete: @escaping (Recipe) -> Void) {
        cancel()
        errorMessage = nil
        configIdToEn = nil
        configEnToId = nil
        englishInstructions = nil
        intermediateBreakdownsEN = nil
        recipe = nil
        state = .idle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.start(url: url, onComplete: onComplete)
        }
    }
    
    private func handleError(_ message: String) {
        Task { @MainActor in
            self.errorMessage = message
            self.hasStarted = false
            self.activeTask?.cancel()
        }
    }
}
