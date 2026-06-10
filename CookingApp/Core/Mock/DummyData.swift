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

            ingredients: [

                Ingredient(
                    id: UUID(),
                    quantity: "",
                    name: "Bahan Sambal Matah",
                    groupIngredients: [
                        Ingredient(id: UUID(), quantity: "10 siung", name: "Bawang Merah", groupIngredients: nil),
                        Ingredient(id: UUID(), quantity: "15 buah", name: "Cabai Rawit Merah", groupIngredients: nil),
                        Ingredient(id: UUID(), quantity: "3 lembar", name: "Daun Jeruk (Buang tulang)", groupIngredients: nil),
                        Ingredient(id: UUID(), quantity: "2 batang", name: "Serai (Ambil putihnya)", groupIngredients: nil),
                        Ingredient(id: UUID(), quantity: "1 buah", name: "Jeruk Nipis", groupIngredients: nil),
                        Ingredient(id: UUID(), quantity: "3 sdm", name: "Minyak Panas", groupIngredients: nil)
                    ]
                ),

                Ingredient(id: UUID(), quantity: "1 bungkus", name: "Mie Instan Kuah", groupIngredients: nil),
                Ingredient(id: UUID(), quantity: "1 butir", name: "Telur Ayam", groupIngredients: nil),
                Ingredient(id: UUID(), quantity: "Secukupnya", name: "Sayur Sawi Hijau", groupIngredients: nil),
                Ingredient(id: UUID(), quantity: "400 ml", name: "Air", groupIngredients: nil),
                Ingredient(id: UUID(), quantity: "3 buah", name: "Cabai Rawit (Opsional)", groupIngredients: nil)
                
            ],
            
            instructions: [
                Instruction(
                    id: UUID(),
                    sequenceNumber: 1,
                    text: "Rebus air dalam panci hingga mendidih.",
                    photoUrl: nil,
                    breakdownInstruction: []
                ),
        
                Instruction(
                    id: UUID(),
                    sequenceNumber: 2,
                    text: "Siapkan bumbu halus.",
                    photoUrl: nil,
                    breakdownInstruction: [
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 1,
                            text: "Kupas bawang merah dan bawang putih.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        ),Instruction(
                            id: UUID(),
                            sequenceNumber: 1,
                            text: "Kupas bawang merah dan bawang putih.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        ),
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 2,
                            text: "Ulek semua bahan bumbu bersama sejumput garam hingga halus.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        ),
    
                        Instruction(
                            id: UUID(),
                            sequenceNumber: 3,
                            text: "Panaskan 2 sdm minyak, lalu tumis bumbu ulek tadi.",
                            photoUrl: nil,
                            breakdownInstruction: []
                        )
                    ]
                ),
                Instruction(
                    id: UUID(),
                    sequenceNumber: 3,
                    text: "Masukkan mie instan dan irisan cabai rawit ke dalam air rebusan.",
                    photoUrl: nil,
                    breakdownInstruction: []
                ),
                Instruction(
                    id: UUID(),
                    sequenceNumber: 4,
                    text: "Masak selama 1 menit.",
                    photoUrl: nil,
                    breakdownInstruction: []
                ),
                Instruction(
                    id: UUID(),
                    sequenceNumber: 5,
                    text: "Campurkan tumisan bumbu halus ke dalam panci mie",
                    photoUrl: nil,
                    breakdownInstruction: []
                ),
                Instruction(
                    id: UUID(),
                    sequenceNumber: 6,
                    text: "Aduk rata dan sajikan selagi hangat.",
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
            ingredients : [],
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
            ingredients : [],
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
            ingredients : [],
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
            ingredients: [],
            instructions: [],
            tips: "Gunakan api besar saat menumis kangkung."
        )
    ]
}
