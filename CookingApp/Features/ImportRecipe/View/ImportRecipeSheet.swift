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
        @State private var tipReady = false
        
        var body: some View {
            ZStack {
                Color.surfaceElevated
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                VStack(spacing: 26) {
                    ZStack {
                        // Judul di tengah
                        Text("Import Resep")
                            .font(.headline)
                        
                        // Tombol X di ujung kiri
                        HStack {
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.headline)
                                    .foregroundColor(Color.labelDark)
                                    .frame(width: 45, height: 45)
                                    .background(Color.surfaceDefault)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                    }
                    
                    VStack(spacing:16) {
                        Text("Masukkan link resep dari website untuk memproses bahan dan langkah memasak secara otomatis.")
                            .font(.body)
                            .tint(Color.brandPrimary)
                            .multilineTextAlignment(.leading)
    //                        .padding()
                        TextField("Masukkan link resep di sini", text: $viewModel.link)
                            .padding(.horizontal,15)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                Color.surfaceDefault
                            )
                            .cornerRadius(Radius.infinity)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .tint(Color.brandPrimary)
                            .trackFrame(in: .named("SheetSpace"), $textFieldFrame)
                            .onChange(of: viewModel.link) { _, _ in
                                viewModel.errorMessage = nil
                                if onboardingStep == 1 {

                                    updateOnboarding(to: 2)
                                }
                            }
                            .conditionalTip(onboardingStep == 1 && tipReady, tip: PasteLinkTip(), arrowEdge: .bottom)
                        
                        // Error message
                        if let errorMessage = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.footnote)
                                Text(errorMessage)
                                    .font(.footnote)
                            }
                            .foregroundColor(Color.actionDelete)
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
            .onAppear {
                guard onboardingStep == 1 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    tipReady = true
                }
            }
            .onDisappear {
                tipReady = false
            }
        }
    }

    //#Preview {
    //    ImportRecipeSheet()
    //}
