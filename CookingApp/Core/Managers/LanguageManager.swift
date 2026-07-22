//
//  LanguageManager.swift
//  CookingApp
//
//  Created by Antigravity on 30/06/26.
//

import Foundation
import Combine

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case indonesian = "id"

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .indonesian: return "Bahasa Indonesia"
        }
    }

    var flag: String {
        switch self {
        case .english:    return "🇺🇸"
        case .indonesian: return "🇮🇩"
        }
    }
}

final class LanguageManager: ObservableObject {

    private static let storageKey = "selectedLanguage"

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .english
    }

    // MARK: - Localized String Lookup

    func localized(_ key: String) -> String {
        let pair = Self.localizedStrings[key]
        switch currentLanguage {
        case .english:    return pair?.en ?? key
        case .indonesian: return pair?.id ?? key
        }
    }

    // MARK: - String Table

    private struct LocalizedPair {
        let en: String
        let id: String
    }

    private static let localizedStrings: [String: LocalizedPair] = [
        // Home
        "home_title":            LocalizedPair(en: "Home",                                    id: "Beranda"),

        // Home Action Buttons
        "import_recipe_title":   LocalizedPair(en: "Import Recipe",                           id: "Import Resep"),
        "import_recipe_desc":    LocalizedPair(en: "Add recipe from website link",            id: "Tambahkan resep dari link website"),
        "write_recipe_title":    LocalizedPair(en: "Write Recipe",                            id: "Tulis Resep"),
        "write_recipe_desc":     LocalizedPair(en: "Create and save your recipe",             id: "Buat dan simpan resepmu"),

        // Home Empty State
        "empty_title":           LocalizedPair(en: "Prepare Recipe and Start Cooking",        id: "Siapkan Resep dan Mulai Masak"),
        "empty_subtitle":        LocalizedPair(en: "Start creating recipes. Try cooking with voice guidance!", id: "Mulai buat resep. Coba memasak dengan panduan suara!"),

        // Home Recipe List Section
        "recipes_section_title": LocalizedPair(en: "Recipes",                                id: "Resep"),
        "see_all":               LocalizedPair(en: "See All",                                id: "Lihat Semua"),
        "close":                 LocalizedPair(en: "Close",                                  id: "Tutup"),

        // Recipe Card
        "minute_short":          LocalizedPair(en: "min",                                    id: "mnt"),

        // Language Settings
        "language_title":        LocalizedPair(en: "Language",                               id: "Bahasa"),
        "language_subtitle":     LocalizedPair(en: "Choose your preferred language",         id: "Pilih bahasa yang kamu inginkan"),
    ]
}
