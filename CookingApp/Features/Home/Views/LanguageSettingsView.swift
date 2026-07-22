//
//  LanguageSettingsView.swift
//  CookingApp
//
//  Created by Antigravity on 30/06/26.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceBrandElevated.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Subtitle
                    Text(languageManager.localized("language_subtitle"))
                        .font(Font.subheadline)
                        .foregroundStyle(Color.labelLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Language options
                    VStack(spacing: 0) {
                        ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    languageManager.currentLanguage = language
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    // Flag
                                    Text(language.flag)
                                        .font(.title2)
                                    
                                    // Language name
                                    Text(language.displayName)
                                        .font(Font.body)
                                        .foregroundStyle(Color.labelDark)
                                    
                                    Spacer()
                                    
                                    // Checkmark
                                    if languageManager.currentLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(Color.brandPrimary)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    languageManager.currentLanguage == language
                                    ? Color.brandPrimary.opacity(0.08)
                                    : Color.clear
                                )
                            }
                            
                            if language != AppLanguage.allCases.last {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color.surfaceDefault)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle(languageManager.localized("language_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.labelLight)
                    }
                }
            }
        }
    }
}

#Preview {
    LanguageSettingsView()
        .environmentObject(LanguageManager())
}
