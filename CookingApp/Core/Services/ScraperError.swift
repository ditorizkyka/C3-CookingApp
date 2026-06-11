//
//  CookpadScraperService.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

//
//  CookpadScraperService.swift
//  CookingApp - Cookpad Scraper
//
//  EXPLANATION:
//  This file is our "Service". We use `WebKit` (WKWebView).
//  Why WebKit? Some websites block basic URL requests or require JavaScript to run before
//  they show their data. By using WKWebView, we create an invisible browser that acts exactly
//  like Safari, loads the page fully, and then we inject JavaScript to grab the data we need!
//

import Foundation
import WebKit

// MARK: - Custom Error Types
enum ScraperError: LocalizedError {
    case invalidURL
    case notCookpadURL
    case networkFailed(Error)
    case noRecipeFound
    case decodingFailed(Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL yang kamu masukkan tidak valid."
        case .notCookpadURL:
            return "Saat ini hanya mendukung link dari Cookpad. Pastikan link berasal dari cookpad.com."
        case .networkFailed(let e):
            return "Gagal terhubung: \(e.localizedDescription)"
        case .noRecipeFound:
            return "Tidak ditemukan data resep di halaman ini. Link mungkin bukan halaman resep atau sudah dihapus."
        case .decodingFailed(let e):
            return "Gagal membaca data resep: \(e.localizedDescription)"
        case .timeout:
            return "Halaman terlalu lama dimuat. Periksa koneksi internet dan coba lagi."
        }
    }
}

// MARK: - WebKit Scraper Service
// We use @MainActor because WKWebView MUST be created and used on the main thread.
@MainActor
final class CookpadScraperService: NSObject, WKNavigationDelegate {
    
    // Singleton so we can reuse the same invisible browser
    static let shared = CookpadScraperService()
    
    private var webView: WKWebView!
    private var continuation: CheckedContinuation<Recipe, Error>?
    
    /// How long (in seconds) we wait after page load for JS to finish rendering
    private let postLoadDelay: TimeInterval = 2.0
    /// Maximum time (in seconds) we wait for the entire scrape operation
    private let timeoutDuration: TimeInterval = 30.0
    
    private override init() {
        super.init()
        let config = WKWebViewConfiguration()
        // Set a Safari-like user agent so sites don't block us
        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.customUserAgent = userAgent
        self.webView.navigationDelegate = self
    }
    
    // MARK: - Validate Cookpad URL
    static func isValidCookpadURL(_ urlString: String) -> Bool {
        let cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let url = URL(string: cleaned), let host = url.host?.lowercased() else {
            return false
        }
        return host.contains("cookpad.com")
    }
    
    // MARK: - Scrape
    func scrape(urlString: String) async throws -> Recipe {
        // Clean up the URL string
        let cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: cleaned), url.scheme != nil else {
            throw ScraperError.invalidURL
        }
        
        // Validate it's a Cookpad URL
        guard CookpadScraperService.isValidCookpadURL(cleaned) else {
            throw ScraperError.notCookpadURL
        }
        
        // Bridge the callback-based WKNavigationDelegate into async/await
        return try await withCheckedThrowingContinuation { continuation in
            // If there's an existing scrape happening, cancel it
            self.continuation?.resume(throwing: ScraperError.networkFailed(NSError(domain: "Cancelled", code: -1)))
            self.continuation = continuation
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutDuration)
            self.webView.load(request)
            
            // Set a timeout
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(self.timeoutDuration * 1_000_000_000))
                if self.continuation != nil {
                    self.continuation?.resume(throwing: ScraperError.timeout)
                    self.continuation = nil
                    self.webView.stopLoading()
                }
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(self.postLoadDelay * 1_000_000_000))
            guard self.continuation != nil else { return }
            self.extractRecipeData(from: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
        self.continuation = nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
        self.continuation = nil
    }
    
    // MARK: - Extract Recipe Data
    private func extractRecipeData(from webView: WKWebView) {
        // JavaScript to find LD+JSON recipe data
        let jsCode = """
            (function() {
                try {
                    var scripts = document.querySelectorAll('script[type="application/ld+json"]');
                    for (var i = 0; i < scripts.length; i++) {
                        var text = scripts[i].textContent || scripts[i].innerText;
                        if (!text) continue;
                        
                        try {
                            var parsed = JSON.parse(text);
                            
                            // Case 1: Direct Recipe object
                            if (parsed['@type'] === 'Recipe') {
                                return JSON.stringify(parsed);
                            }
                            
                            // Case 2: @graph array containing Recipe
                            if (parsed['@graph'] && Array.isArray(parsed['@graph'])) {
                                for (var j = 0; j < parsed['@graph'].length; j++) {
                                    var item = parsed['@graph'][j];
                                    if (item['@type'] === 'Recipe') {
                                        return JSON.stringify(item);
                                    }
                                }
                            }
                            
                            // Case 3: Array of objects at the top level
                            if (Array.isArray(parsed)) {
                                for (var k = 0; k < parsed.length; k++) {
                                    if (parsed[k]['@type'] === 'Recipe') {
                                        return JSON.stringify(parsed[k]);
                                    }
                                }
                            }
                        } catch(e) {
                            continue;
                        }
                    }
                    
                    // Fallback: Try to find ANY script tag that mentions Recipe
                    for (var m = 0; m < scripts.length; m++) {
                        var rawText = scripts[m].textContent || scripts[m].innerText;
                        if (rawText && rawText.indexOf('"Recipe"') !== -1) {
                            return rawText;
                        }
                    }
                    
                    return null;
                } catch(err) {
                    return null;
                }
            })();
        """
        
        webView.evaluateJavaScript(jsCode) { [weak self] result, error in
            guard let self = self else { return }
            guard self.continuation != nil else { return }
            
            if let jsonString = result as? String, let jsonData = jsonString.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    // Decode into intermediate Codable struct first
                    let rawRecipe = try decoder.decode(CookpadRawRecipe.self, from: jsonData)
                    // Map to SwiftData model
                    let recipe = rawRecipe.toRecipe()
                    self.continuation?.resume(returning: recipe)
                } catch {
                    self.continuation?.resume(throwing: ScraperError.decodingFailed(error))
                }
            } else {
                let err = error ?? ScraperError.noRecipeFound
                self.continuation?.resume(throwing: err)
            }
            
            self.continuation = nil
        }
    }
}
