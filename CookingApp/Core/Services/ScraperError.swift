//
//  CookpadScraperService.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

//
//  CookpadScraperService.swift
//  CookingApp - Universal Recipe Scraper
//
//  EXPLANATION:
//  This file is our "Service". We use `WebKit` (WKWebView).
//  Why WebKit? Some websites block basic URL requests or require JavaScript to run before
//  they show their data. By using WKWebView, we create an invisible browser that acts exactly
//  like Safari, loads the page fully, and then we inject JavaScript to grab the data we need!
//
//  STRATEGY (Universal — supports ANY recipe website):
//  1. PRIMARY: Look for JSON-LD structured data (Schema.org Recipe)
//     → This is the standard most recipe sites use (AllRecipes, BBC Good Food, Tasty, Cookpad, etc.)
//  2. FALLBACK: If no JSON-LD found, scrape Open Graph meta tags for basic info
//     → This gives us at least the title, image, and description
//  3. NLP FALLBACK: If JSON-LD has no ingredients/instructions (article websites),
//     use ArticleRecipeExtractor (Apple Intelligence) to extract from raw page text
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
            return "URL yang kamu masukkan tidak valid. Pastikan dimulai dengan https://"
        case .notCookpadURL:
            return "Saat ini hanya mendukung link dari Cookpad. Pastikan link berasal dari cookpad.com."
        case .networkFailed(let e):
            return "Gagal terhubung: \(e.localizedDescription)"
        case .noRecipeFound:
            return "Tidak ditemukan data resep di halaman ini. Situs mungkin tidak menggunakan format resep standar, atau link bukan halaman resep."
        case .decodingFailed(let e):
            return "Gagal membaca data resep: \(e.localizedDescription)"
        case .timeout:
            return "Halaman terlalu lama dimuat. Periksa koneksi internet dan coba lagi."
        }
    }
}

// MARK: - WebKit Scraper Service (Universal — supports ANY recipe website)
// We use @MainActor because WKWebView MUST be created and used on the main thread.
@MainActor
final class CookpadScraperService: NSObject, WKNavigationDelegate {
    
    // Singleton so we can reuse the same invisible browser
    static let shared = CookpadScraperService()
    
    private var webView: WKWebView!
    private var continuation: CheckedContinuation<Recipe, Error>?
    private var currentURL: String = ""
    
    /// How long (in seconds) we wait after page load for JS to finish rendering
    private let postLoadDelay: TimeInterval = 3.0
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
    
    // MARK: - Scrape (Universal — any recipe URL)
    func scrape(urlString: String) async throws -> Recipe {
        // Clean up the URL string
        let cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Auto-add https:// if missing
        let finalURL: String
        if cleaned.hasPrefix("http://") || cleaned.hasPrefix("https://") {
            finalURL = cleaned
        } else {
            finalURL = "https://" + cleaned
        }
        
        print("\n🌐 [SCRAPER] Starting universal scrape...")
        print("🌐 [SCRAPER] URL: \(finalURL)")
        
        guard let url = URL(string: finalURL), url.scheme != nil, url.host != nil else {
            print("❌ [SCRAPER] Invalid URL format")
            throw ScraperError.invalidURL
        }
        
        self.currentURL = finalURL
        
        print("✅ [SCRAPER] URL validated. Loading page with WKWebView...")
        
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
                    print("⏰ [SCRAPER] Timeout after \(self.timeoutDuration)s")
                    self.continuation?.resume(throwing: ScraperError.timeout)
                    self.continuation = nil
                    self.webView.stopLoading()
                }
            }
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("📄 [SCRAPER] Page finished loading. Waiting \(postLoadDelay)s for JS rendering...")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(self.postLoadDelay * 1_000_000_000))
            guard self.continuation != nil else { return }
            print("🔍 [SCRAPER] Extracting recipe data via enhanced JavaScript...")
            self.extractRecipeData(from: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ [SCRAPER] Navigation failed: \(error.localizedDescription)")
        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
        self.continuation = nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ [SCRAPER] Provisional navigation failed: \(error.localizedDescription)")
        self.continuation?.resume(throwing: ScraperError.networkFailed(error))
        self.continuation = nil
    }
    
    // MARK: - Extract Recipe Data (Enhanced Universal JavaScript)
    private func extractRecipeData(from webView: WKWebView) {
        // ENHANCED: The JavaScript now returns a WRAPPER object containing:
        //   1. "recipeJSON" — the raw Recipe JSON-LD string (for decoding)
        //   2. "pageText"   — the full visible text of the page (for NLP fallback)
        //
        // This lets us:
        //   - Decode JSON-LD using ScrapedRecipeDTO (universal) or CookpadRawRecipe (legacy)
        //   - Fall back to NLP extraction via ArticleRecipeExtractor when JSON-LD lacks data
        let jsCode = """
            (function() {
                try {
                    var result = { recipeJSON: null, pageText: '' };

                    // ========== STRATEGY: Smart Text Extraction ==========
                    // document.body.innerText sometimes smashes list items together without newlines.
                    // This custom extractor forces newlines after block elements (p, div, li)
                    function extractSmartText(node) {
                        if (node.nodeType === Node.TEXT_NODE) {
                            return node.textContent;
                        }
                        if (node.nodeType !== Node.ELEMENT_NODE) {
                            return '';
                        }
                        
                        // Ignore invisible elements or scripts/styles
                        let style = window.getComputedStyle(node);
                        if (style.display === 'none' || style.visibility === 'hidden' || 
                            node.tagName === 'SCRIPT' || node.tagName === 'STYLE' || node.tagName === 'NOSCRIPT') {
                            return '';
                        }

                        let text = '';
                        for (let child of node.childNodes) {
                            text += extractSmartText(child);
                        }

                        // Add newlines after block elements to ensure NLP sees separate lines
                        let blockTags = ['P', 'DIV', 'LI', 'BR', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'TR', 'UL', 'OL'];
                        if (blockTags.includes(node.tagName)) {
                            text += '\\n';
                        }
                        
                        // If this is a list item, prefix with a bullet so NLP treats it as a distinct item
                        if (node.tagName === 'LI') {
                            text = '• ' + text.trim() + '\\n';
                        }

                        return text;
                    }

                    // Grab smart visible page text (for NLP fallback)
                    if (document.body) {
                        let rawText = extractSmartText(document.body);
                        result.pageText = rawText.replace(/\\n\\s*\\n/g, '\\n').substring(0, 20000);
                    } else {
                        result.pageText = '';
                    }

                    // ========== STRATEGY 1: JSON-LD Structured Data ==========
                    var scripts = document.querySelectorAll('script[type="application/ld+json"]');
                    var recipes = [];

                    function isRecipeType(item) {
                        if (!item) return false;
                        var t = item['@type'];
                        if (!t) return false;
                        if (typeof t === 'string') return t === 'Recipe';
                        if (Array.isArray(t)) return t.indexOf('Recipe') !== -1;
                        return false;
                    }

                    function findRecipesInObject(obj) {
                        if (!obj || typeof obj !== 'object') return;
                        if (isRecipeType(obj)) {
                            recipes.push(obj);
                            return;
                        }
                        if (obj['@graph'] && Array.isArray(obj['@graph'])) {
                            for (var i = 0; i < obj['@graph'].length; i++) {
                                findRecipesInObject(obj['@graph'][i]);
                            }
                        }
                        if (Array.isArray(obj)) {
                            for (var j = 0; j < obj.length; j++) {
                                findRecipesInObject(obj[j]);
                            }
                        }
                    }

                    for (var i = 0; i < scripts.length; i++) {
                        var text = scripts[i].textContent || scripts[i].innerText;
                        if (!text) continue;
                        try {
                            var parsed = JSON.parse(text);
                            findRecipesInObject(parsed);
                        } catch(e) { continue; }
                    }

                    if (recipes.length > 0) {
                        // Pick the recipe with the most fields (most complete data)
                        var best = recipes[0];
                        var bestKeys = Object.keys(best).length;
                        for (var r = 1; r < recipes.length; r++) {
                            var keys = Object.keys(recipes[r]).length;
                            if (keys > bestKeys) {
                                best = recipes[r];
                                bestKeys = keys;
                            }
                        }
                        result.recipeJSON = JSON.stringify(best);
                        return JSON.stringify(result);
                    }

                    // ========== STRATEGY 2: Open Graph Meta Fallback ==========
                    var ogTitle = '';
                    var ogImage = '';
                    var ogDesc = '';
                    var metas = document.querySelectorAll('meta');
                    for (var m = 0; m < metas.length; m++) {
                        var prop = metas[m].getAttribute('property') || metas[m].getAttribute('name') || '';
                        var content = metas[m].getAttribute('content') || '';
                        if (prop === 'og:title') ogTitle = content;
                        if (prop === 'og:image') ogImage = content;
                        if (prop === 'og:description') ogDesc = content;
                    }
                    if (!ogTitle) ogTitle = document.title || '';

                    if (ogTitle) {
                        var fallback = {
                            "@type": "Recipe",
                            "name": ogTitle,
                            "description": ogDesc,
                            "image": ogImage
                        };
                        result.recipeJSON = JSON.stringify(fallback);
                        return JSON.stringify(result);
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
            
            if let wrapperString = result as? String,
               let wrapperData = wrapperString.data(using: .utf8) {
                
                do {
                    // Parse the wrapper to get recipeJSON and pageText
                    guard let wrapper = try JSONSerialization.jsonObject(with: wrapperData) as? [String: Any],
                          let recipeJSONString = wrapper["recipeJSON"] as? String,
                          let recipeData = recipeJSONString.data(using: .utf8) else {
                        self.continuation?.resume(throwing: ScraperError.noRecipeFound)
                        self.continuation = nil
                        return
                    }
                    
                    let pageText = wrapper["pageText"] as? String ?? ""
                    
                    // ========== PRINT FULL RAW SCRAPING RESULT ==========
                    print("\n" + String(repeating: "=", count: 60))
                    print("🌐 FULL RAW SCRAPING RESULT")
                    print(String(repeating: "=", count: 60))
                    print("📎 Source URL: \(self.currentURL)")
                    print(String(repeating: "-", count: 60))
                    print("📄 RAW JSON-LD DATA:")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: recipeData),
                       let prettyData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted),
                       let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    } else {
                        print(recipeJSONString)
                    }
                    print(String(repeating: "-", count: 60))
                    print("📝 RAW PAGE TEXT (first 3000 chars):")
                    print(String(pageText.prefix(3000)))
                    print(String(repeating: "=", count: 60) + "\n")
                    
                    // Store page text for potential NLP processing
                    self.lastPageText = pageText
                    
                    // ========== DECODE: Try ScrapedRecipeDTO first (universal), fallback to CookpadRawRecipe ==========
                    let decoder = JSONDecoder()
                    var recipe: Recipe
                    
                    if let dto = try? decoder.decode(ScrapedRecipeDTO.self, from: recipeData) {
                        print("✅ [SCRAPER] Successfully decoded ScrapedRecipeDTO (universal)")
                        recipe = dto.toRecipe()
                    } else if let rawRecipe = try? decoder.decode(CookpadRawRecipe.self, from: recipeData) {
                        print("✅ [SCRAPER] Fallback: decoded CookpadRawRecipe (legacy)")
                        recipe = rawRecipe.toRecipe()
                    } else {
                        // If both decoders fail, try a more lenient approach
                        print("⚠️ [SCRAPER] Both decoders failed, attempting lenient decode...")
                        let dto = try decoder.decode(ScrapedRecipeDTO.self, from: recipeData)
                        recipe = dto.toRecipe()
                    }
                    
                    print("✅ [SCRAPER] Successfully mapped to Recipe model")
                    
                    // ========== NLP FALLBACK: If JSON-LD has no ingredients/instructions ==========
                    let hasIngredients = !recipe.ingredients.isEmpty
                    let hasInstructions = !recipe.instructions.isEmpty
                    
                    if (!hasIngredients || !hasInstructions) && !pageText.isEmpty {
                        print("⚠️ [SCRAPER] JSON-LD incomplete (ingredients: \(hasIngredients), instructions: \(hasInstructions))")
                        print("🤖 [SCRAPER] Attempting NLP extraction via ArticleRecipeExtractor...")
                        
                        #if canImport(FoundationModels)
                        if #available(iOS 26.0, *) {
                            Task { @MainActor in
                                do {
                                    let extractor = ArticleRecipeExtractor()
                                    let nlpResult = try await extractor.extractRecipe(
                                        from: pageText,
                                        title: recipe.title
                                    )
                                    
                                    // Fill in missing ingredients from NLP
                                    if !hasIngredients && !nlpResult.ingredients.isEmpty {
                                        let nlpIngredients = nlpResult.ingredients.map { raw -> Ingredient in
                                            let parts = ScrapedRecipeDTO.parseIngredientString(raw)
                                            return Ingredient(quantity: parts.quantity, name: parts.name)
                                        }
                                        recipe.ingredients = nlpIngredients
                                        print("✅ [NLP] Filled \(nlpIngredients.count) ingredients from article text")
                                    }
                                    
                                    // Fill in missing instructions from NLP
                                    if !hasInstructions && !nlpResult.instructions.isEmpty {
                                        let nlpInstructions = nlpResult.instructions.enumerated().map { index, text in
                                            Instruction(sequenceNumber: index + 1, text: text)
                                        }
                                        recipe.instructions = nlpInstructions
                                        print("✅ [NLP] Filled \(nlpInstructions.count) instructions from article text")
                                    }
                                    
                                    // Update recipe name if NLP found one and current is generic
                                    if !nlpResult.recipeName.isEmpty && (recipe.title == "Resep Tanpa Judul" || recipe.title == "Unknown Recipe") {
                                        recipe.title = nlpResult.recipeName
                                    }
                                    
                                    self.continuation?.resume(returning: recipe)
                                    self.continuation = nil
                                } catch {
                                    print("⚠️ [NLP] Article extraction failed: \(error.localizedDescription)")
                                    print("📋 [SCRAPER] Returning recipe with available JSON-LD data only")
                                    self.continuation?.resume(returning: recipe)
                                    self.continuation = nil
                                }
                            }
                            return // Don't resume below — NLP Task handles it
                        }
                        #endif
                        
                        // If FoundationModels not available, return whatever we have
                        print("📋 [SCRAPER] FoundationModels not available, returning partial recipe")
                    }
                    
                    self.continuation?.resume(returning: recipe)
                } catch {
                    print("❌ [SCRAPER] Decoding failed: \(error)")
                    self.continuation?.resume(throwing: ScraperError.decodingFailed(error))
                }
            } else {
                print("❌ [SCRAPER] No recipe data found in page")
                if let error = error {
                    print("❌ [SCRAPER] JS error: \(error)")
                }
                let err = error ?? ScraperError.noRecipeFound
                self.continuation?.resume(throwing: err)
            }
            
            self.continuation = nil
        }
    }
    
    // MARK: - Page Text for NLP
    // After scraping, the raw page text is stored here for potential NLP processing.
    private(set) var lastPageText: String = ""
}
