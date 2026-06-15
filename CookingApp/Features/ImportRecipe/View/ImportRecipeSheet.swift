//
//  ImportRecipeSheet.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

import SwiftUI
import TipKit

struct ImportRecipeSheet: View {
    var onImport: ((String) -> Void)
    
    @StateObject private var viewModel = ImportRecipeViewModel()
    
    // Untuk menutup sheet
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    @State private var textFieldFrame: CGRect = .zero
    
    let pasteLinkTip = ToolTip(tipTitle: "Tempel Link", tipSubtitle: "Gunakan link resep yang sudah terisi otomatis di sini ini untuk mencoba fitur ekstrak resep.", iconName: "doc.on.clipboard.fill", buttonTitle: "")
    
    var body: some View {
        ZStack {
            Color.surfaceElevated
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            VStack(spacing: 32) {
                ZStack {
                    // Judul di tengah
                    Text("Import Resep")
                        .font(.headline) // Atau .title3
                    
                    // Tombol X di ujung kiri
                    HStack {
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(width: 45, height: 45)
                                .background(Color(UIColor.secondarySystemFill)) // Warna bulat abu-abu
                                .clipShape(Circle())
                        }
                        Spacer() // Mendorong tombol ke ujung kiri
                    }
                }
                
                VStack(spacing:16) {
                    Text("Masukkan link resep (cth: Cookpad) untuk memproses bahan dan panduan masak secara otomatis")
                        .font(.body)
                    TextField("Masukkan link resep di sini", text: $viewModel.link)
                        .padding(.horizontal,15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color(UIColor.tertiarySystemFill)
                        )
                        .cornerRadius(Radius.infinity)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .tint(Color.brandPrimary)
                        .trackFrame(in: .named("SheetSpace"), $textFieldFrame)
                        .onChange(of: viewModel.link) { _, _ in
                            // Clear error when user edits the link
                            viewModel.errorMessage = nil
                            if onboardingStep == 1 {
                                onboardingStep = 2
                            }
                        }
                        .conditionalPopoverTip(onboardingStep == 1, tip: pasteLinkTip, arrowEdge: .bottom)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.footnote)
                            Text(errorMessage)
                                .font(.footnote)
                        }
                        .foregroundColor(Color.actionDelete!)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                }
                VStack(spacing: 8) {
                    ButtonApp(title: "Import Recipe", action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.validateAndShowPreview()
                        }
                    })
                    ButtonApp(title: "Cancel", type: .tertiary, action: {
                        dismiss()
                    })
                }
            }

            .padding(.horizontal,24)
//            .padding(.bottom, 36) 
            // Preview Sheet
            .sheet(isPresented: $viewModel.showWebPreview) {
                WebsitePreviewSheet(
                    urlString: viewModel.link,
                    onImport: {
                        viewModel.showWebPreview = false
                        dismiss()
                        // Tell parent to navigate to LoadingRecipeView with the URL
                        onImport(viewModel.link)
                    },
                    onDismiss: {
                        viewModel.showWebPreview = false
                    }
                )
            }
            
        }
        .coordinateSpace(name: "SheetSpace")
        .holeMaskOverlay(isActive: Binding(get: { onboardingStep == 1 }, set: { if !$0 && onboardingStep == 1 { onboardingStep = 2 } }), holeFrame: textFieldFrame, cornerRadius: Radius.infinity)
        .interactiveDismissDisabled(onboardingStep == 1)
    }
}

//#Preview {
//    ImportRecipeSheet()
//}
