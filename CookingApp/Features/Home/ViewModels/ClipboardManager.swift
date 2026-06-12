//
//  ClipboardManager.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 10/06/26.
//

import SwiftUI
import Combine

@MainActor
final class ClipboardManager: ObservableObject {
    @Published var detectedURL: String? = nil
    @Published var showClipboardToast: Bool = false
    
    // Menyimpan URL terakhir agar popup tidak muncul berulang kali untuk URL yang sama
    private var lastProcessedURL: String? = nil
    private var timer: Timer?
    
    // Track the pasteboard change count so we only act on real changes
    private var lastChangeCount: Int = -1
    
    // Domain yang ingin dideteksi (bisa ditambahkan domain lain)
    private let supportedDomains = [
        "cookpad.com",
        "allrecipes.com",
        "food.com",
        "yummy.co.id",
        "sajian sedap.com"
    ]
    
    func startMonitoring() {
        // Snapshot current change count so we don't fire immediately for stale content
        lastChangeCount = UIPasteboard.general.changeCount
        
        // Poll every 1 second for responsiveness
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Call this when the app comes back to the foreground so we re-check immediately.
    func checkNow() {
        checkClipboard()
    }
    
    private func checkClipboard() {
        let currentChangeCount = UIPasteboard.general.changeCount
        
        // Only act if the clipboard has actually changed
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount
        
        // Try URL first (more reliable), then fall back to raw string parsing
        var clipboardString: String?
        
        if UIPasteboard.general.hasURLs,
           let url = UIPasteboard.general.url {
            clipboardString = url.absoluteString
        } else if let raw = UIPasteboard.general.string {
            // Attempt to parse the raw string as a URL
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if URL(string: trimmed)?.scheme?.hasPrefix("http") == true {
                clipboardString = trimmed
            }
        }
        
        guard let clipboardString else { return }
        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate it is a proper http(s) URL from a supported domain
        guard let url = URL(string: trimmed),
              let host = url.host?.lowercased(),
              url.scheme == "http" || url.scheme == "https" else { return }
        
        let isSupported = supportedDomains.contains { domain in
            host == domain || host.hasSuffix(".\(domain)")
        }
        
        guard isSupported else { return }
        
        // Show toast only if this is a different URL than the last one shown
        if trimmed != lastProcessedURL {
            lastProcessedURL = trimmed
            detectedURL = trimmed
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showClipboardToast = true
            }
        }
    }
    
    func dismissToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            showClipboardToast = false
        }
    }
}