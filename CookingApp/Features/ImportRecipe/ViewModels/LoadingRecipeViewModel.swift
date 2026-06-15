import SwiftUI
import Combine

@MainActor
class LoadingRecipeViewModel: ObservableObject {
    @Published var scrapedRecipe: Recipe?
    @Published var errorMessage: String?
    private var hasStartedScraping = false
    
    // Dependencies
    private let scraperService = CookpadScraperService.shared
    
    func startScraping(url: String, onComplete: @escaping (Recipe) -> Void, onError: ((String) -> Void)?) {
        guard !hasStartedScraping else { return }
        hasStartedScraping = true
        
        Task {
            do {
                let result = try await scraperService.scrape(urlString: url)
                self.scrapedRecipe = result
                onComplete(result)
            } catch let error as ScraperError {
                self.errorMessage = error.errorDescription
                onError?(error.errorDescription ?? "Unknown error")
            } catch {
                self.errorMessage = error.localizedDescription
                onError?(error.localizedDescription)
            }
        }
    }
}
