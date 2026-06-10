//
//  WebView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//


//
//  WebView.swift
//  TechnicalFeasibility - Challenge 1 / Cookpad Scraper
//
//  EXPLANATION FOR LEARNER:
//  This is a simple wrapper for WKWebView that allows us to display
//  a webpage inside a SwiftUI View. We use this to preview the Cookpad page.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Adding a user agent just in case it prevents blocks
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
