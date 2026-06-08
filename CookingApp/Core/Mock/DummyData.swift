//
//  DummyData.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//
import Foundation

// MARK: - Dummy Data / Mock Data
extension Recipe {
    static let dummyRecipes: [Recipe] = [
        Recipe(
            id: UUID(),
            title: "Mie Kuah Spesial",
            author: Author(
                id: UUID(),
                name: "Dapur Cepat",
                username: "@dapurcepat",
                avatarUrl: nil
            ),
            coverImageUrl: nil,
            portion: 1,
            durationInMinutes: 10,
            ingredientGroups: [
                
                IngredientGroup(
                                    id: UUID(),
                                    groupName: "Bahan Sambal Matah",
                                    items: [
                                        Ingredient(id: UUID(), quantity: "10 siung", name: "Bawang Merah"),
                                        Ingredient(id: UUID(), quantity: "15 buah", name: "Cabai Rawit Merah"),
                                        Ingredient(id: UUID(), quantity: "3 lembar", name: "Daun Jeruk (Buang tulang)"),
                                        Ingredient(id: UUID(), quantity: "2 batang", name: "Serai (Ambil putihnya)"),
                                        Ingredient(id: UUID(), quantity: "1 buah", name: "Jeruk Nipis"),
                                        Ingredient(id: UUID(), quantity: "3 sdm", name: "Minyak Panas")
                                    ]
                                ),

                // Kunci untuk resep tanpa grup:
                // Cukup buat 1 IngredientGroup dan set groupName menjadi nil
                IngredientGroup(
                    id: UUID(),
                    groupName: nil,
                    items: [
                        Ingredient(id: UUID(), quantity: "1 bungkus", name: "Mie Instan Kuah"),
                        Ingredient(id: UUID(), quantity: "1 butir", name: "Telur Ayam"),
                        Ingredient(id: UUID(), quantity: "Secukupnya", name: "Sayur Sawi Hijau"),
                        Ingredient(id: UUID(), quantity: "400 ml", name: "Air"),
                        Ingredient(id: UUID(), quantity: "3 buah", name: "Cabai Rawit (Opsional)")
                    ]
                )
            ],
            instructions: [
                
                // ==========================================
                // STEP 1: Instruksi Biasa (Tanpa Breakdown)
                // ==========================================
                Instruction(
                    id: UUID(),
                    sequenceNumber: 1,
                    text: "Rebus air dalam panci hingga mendidih.",
                    photoUrl: nil,
                    breakdownInstruction: [] // <-- Gunakan array kosong untuk instruksi tanpa breakdown
                ),
                
                // ==========================================
                // STEP 2: Instruksi Kompleks (Dengan Breakdown)
                // ==========================================
                Instruction(
                    id: UUID(),
                    sequenceNumber: 2,
                    text: "Siapkan bumbu halus dan tumis hingga harum.",
                    photoUrl: nil,
                    breakdownInstruction: [
                        // Sub-step 2.1
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 1,
                            text: "Kupas bawang merah dan bawang putih.",
                            photoUrl: nil,
                            breakdownInstruction: [] // Sub-step biasanya tidak punya breakdown lagi
                        ),
                        // Sub-step 2.2
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 2,
                            text: "Ulek semua bahan bumbu bersama sejumput garam hingga halus.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        ),
                        // Sub-step 2.3
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 3,
                            text: "Panaskan 2 sdm minyak, lalu tumis bumbu ulek tadi.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        )
                    ]
                ),
                
                // ==========================================
                // STEP 3: Instruksi Biasa (Tanpa Breakdown)
                // ==========================================
                Instruction(
                    id: UUID(),
                    sequenceNumber: 3,
                    text: "Masukkan mie instan dan irisan cabai rawit ke dalam air rebusan. Masak selama 1 menit.",
                    photoUrl: nil,
                    breakdownInstruction: []
                ),
                
                // ==========================================
                // STEP 4: Instruksi Biasa (Tanpa Breakdown)
                // ==========================================
                Instruction(
                    id: UUID(),
                    sequenceNumber: 4,
                    text: "Campurkan tumisan bumbu halus ke dalam panci mie. Aduk rata dan sajikan selagi hangat.",
                    photoUrl: nil,
                    breakdownInstruction: []
                )
            ],
            tips: "Jangan merebus mie terlalu lama agar teksturnya tetap kenyal."
        ),
        Recipe(
            id: UUID(),
            title: "Ayam Goreng Lengkuas",
            author: Author(id: UUID(), name: "Dapur Nenek", username: "@dapurnenek", avatarUrl: nil),
            coverImageUrl: nil,
            portion: 4,
            durationInMinutes: 45,
            ingredientGroups: [],
            instructions: [],
            tips: "Goreng dengan api sedang agar matang merata."
        ),
        Recipe(
            id: UUID(),
            title: "Sayur Sop Bening",
            author: Author(id: UUID(), name: "Masak Praktis", username: "@masakpraktis", avatarUrl: nil),
            coverImageUrl: nil,
            portion: 5,
            durationInMinutes: 20,
            ingredientGroups: [],
            instructions: [],
            tips: "Masukkan seledri dan daun bawang di akhir agar tetap segar."
        ),
        Recipe(
            id: UUID(),
            title: "Telur Balado Spesial",
            author: Author(id: UUID(), name: "Cita Rasa", username: "@citarasa", avatarUrl: nil),
            coverImageUrl: nil,
            portion: 2,
            durationInMinutes: 15,
            ingredientGroups: [],
            instructions: [],
            tips: "Gunakan cabai keriting agar tidak terlalu pedas."
        ),
        Recipe(
            id: UUID(),
            title: "Tumis Kangkung Terasi",
            author: Author(id: UUID(), name: "Dapur Kilat", username: "@dapurkilat", avatarUrl: nil),
            coverImageUrl: nil,
            portion: 3,
            durationInMinutes: 10,
            ingredientGroups: [],
            instructions: [],
            tips: "Gunakan api besar saat menumis kangkung."
        )
    ]
}
