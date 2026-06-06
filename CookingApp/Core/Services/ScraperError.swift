////
////  ScraperError.swift
////  CookingApp
////
////  Created by Andito Rizkyka Rianto on 06/06/26.
////
//
//
////
////  CookpadScraperService.swift
////  TechnicalFeasibility - Challenge 1 / Cookpad Scraper
////
////  EXPLANATION FOR LEARNER:
////  This file is our "Service". Based on your requirement, we are now using `WebKit` (WKWebView).
////  Why WebKit? Some websites block basic URL requests or require JavaScript to run before
////  they show their data. By using WKWebView, we create an invisible browser that acts exactly
////  like Safari, loads the page fully, and then we inject JavaScript to grab the data we need!
////
//
//import Foundation
//import WebKit
//
//// MARK: - Custom Error Types
//enum ScraperError: LocalizedError {
//    case invalidURL
//    case networkFailed(Error)
//    case noRecipeFound
//    case decodingFailed(Error)
//    case timeout
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "The URL you entered is not valid."
//        case .networkFailed(let e):
//            return "Network error: \(e.localizedDescription)"
//        case .noRecipeFound:
//            return "No recipe data found on this page. (The link might be a 404 Not Found, or it's not a recipe page)."
//        case .decodingFailed(let e):
//            return "Failed to read recipe data: \(e.localizedDescription)"
//        case .timeout:
//            return "The page took too long to load. Please check your internet connection and try again."
//        }
//    }
//}
//
//// MARK: - WebKit Scraper Service
//// We use @MainActor because WKWebView MUST be created and used on the main thread.
//@MainActor
//final class CookpadScraperService: NSObject, WKNavigationDelegate {
//    
//    // We make a shared instance (Singleton) so we can reuse the same invisible browser
//    static let shared = CookpadScraperService()
//    
//    private var webView: WKWebView!
//    private var continuation: CheckedContinuation<Recipe, Error>?
//    
//    /// How long (in seconds) we wait after page load for JS to finish rendering
//    private let postLoadDelay: TimeInterval = 2.0
//    /// Maximum time (in seconds) we wait for the entire scrape operation
//    private let timeoutDuration: TimeInterval = 30.0
//    
//    private override init() {
//        super.init()
//        let config = WKWebViewConfiguration()
//        // Set a Safari-like user agent so sites don't block us
//        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
//        self.webView = WKWebView(frame: .zero, configuration: config)
//        self.webView.customUserAgent = userAgent
//        self.webView.navigationDelegate = self
//    }
//    
//    // This is the function the View will call
//    func scrape(urlString: String) async throws -> Recipe {
//        // Clean up the URL string (trim whitespace, newlines)
//        let cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard let url = URL(string: cleaned), url.scheme != nil else {
//            throw ScraperError.invalidURL
//        }
//        
//        // We use withCheckedThrowingContinuation to bridge the callback-based
//        // WKNavigationDelegate into modern async/await syntax.
//        return try await withCheckedThrowingContinuation { continuation in
//            // If there's an existing scrape happening, cancel it
//            self.continuation?.resume(throwing: ScraperError.networkFailed(NSError(domain: "Cancelled", code: -1)))
//            self.continuation = continuation
//            
//            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutDuration)
//            self.webView.load(request) // Start loading the invisible browser
//            
//            // Set a timeout — if the page takes too long, we give up
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: UInt64(self.timeoutDuration * 1_000_000_000))
//                // Only fire if the continuation hasn't been consumed yet
//                if self.continuation != nil {
//                    self.continuation?.resume(throwing: ScraperError.timeout)
//                    self.continuation = nil
//                    self.webView.stopLoading()
//                }
//            }
//        }
//    }
//    
//    // MARK: - WKNavigationDelegate Methods
//    
//    // 1. This is called when the invisible browser FINISHES loading the page.
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        // Wait a short delay to let any late JavaScript finish rendering on the page.
//        // Some sites inject content via JS after the page load event fires.
//        Task { @MainActor in
//            try? await Task.sleep(nanoseconds: UInt64(self.postLoadDelay * 1_000_000_000))
//            
//            // Make sure we haven't timed out already
//            guard self.continuation != nil else { return }
//            
//            self.extractRecipeData(from: webView)
//        }
//    }
//    
//    // 2. This is called if the network fails completely (e.g. no internet)
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
//        self.continuation = nil
//    }
//    
//    // 3. This is called if the page fails to load initially (e.g. invalid server)
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
//        self.continuation = nil
//    }
//    
//    // MARK: - Extract Recipe Data
//    // This is where the magic happens! We inject JavaScript to find the recipe data.
//    private func extractRecipeData(from webView: WKWebView) {
//        // This JavaScript is MUCH more robust than before:
//        // 1. It collects ALL ld+json script tags
//        // 2. It parses each one as JSON
//        // 3. It handles @graph arrays (finds the Recipe inside the array)
//        // 4. It handles top-level Recipe objects
//        // 5. It returns the first Recipe object found as a JSON string
//        let jsCode = """
//            (function() {
//                try {
//                    var scripts = document.querySelectorAll('script[type="application/ld+json"]');
//                    for (var i = 0; i < scripts.length; i++) {
//                        var text = scripts[i].textContent || scripts[i].innerText;
//                        if (!text) continue;
//                        
//                        try {
//                            var parsed = JSON.parse(text);
//                            
//                            // Case 1: Direct Recipe object
//                            if (parsed['@type'] === 'Recipe') {
//                                return JSON.stringify(parsed);
//                            }
//                            
//                            // Case 2: @graph array containing Recipe
//                            if (parsed['@graph'] && Array.isArray(parsed['@graph'])) {
//                                for (var j = 0; j < parsed['@graph'].length; j++) {
//                                    var item = parsed['@graph'][j];
//                                    if (item['@type'] === 'Recipe') {
//                                        return JSON.stringify(item);
//                                    }
//                                }
//                            }
//                            
//                            // Case 3: Array of objects at the top level
//                            if (Array.isArray(parsed)) {
//                                for (var k = 0; k < parsed.length; k++) {
//                                    if (parsed[k]['@type'] === 'Recipe') {
//                                        return JSON.stringify(parsed[k]);
//                                    }
//                                }
//                            }
//                        } catch(e) {
//                            // This ld+json block had invalid JSON, skip it
//                            continue;
//                        }
//                    }
//                    
//                    // Fallback: Try to find ANY script tag that mentions Recipe
//                    // (some sites put it in a non-standard way)
//                    for (var m = 0; m < scripts.length; m++) {
//                        var rawText = scripts[m].textContent || scripts[m].innerText;
//                        if (rawText && rawText.indexOf('"Recipe"') !== -1) {
//                            return rawText;
//                        }
//                    }
//                    
//                    return null;
//                } catch(err) {
//                    return null;
//                }
//            })();
//        """
//        
//        webView.evaluateJavaScript(jsCode) { [weak self] result, error in
//            guard let self = self else { return }
//            // Make sure continuation hasn't been consumed
//            guard self.continuation != nil else { return }
//            
//            if let jsonString = result as? String, let jsonData = jsonString.data(using: .utf8) {
//                // Successfully got the JSON string from WebKit! Now decode it to our Swift struct.
//                do {
//                    let decoder = JSONDecoder()
//                    let recipe = try decoder.decode(Recipe.self, from: jsonData)
//                    self.continuation?.resume(returning: recipe)
//                } catch {
//                    self.continuation?.resume(throwing: ScraperError.decodingFailed(error))
//                }
//            } else {
//                // If result is null or error happened
//                let err = error ?? ScraperError.noRecipeFound
//                self.continuation?.resume(throwing: err)
//            }
//            
//            self.continuation = nil
//        }
//    }
//}
