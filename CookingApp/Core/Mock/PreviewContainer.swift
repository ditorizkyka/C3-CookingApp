//
//  PreviewContainer.swift
//  CookingApp
//
//  Helper to create an in-memory SwiftData ModelContainer for Xcode Previews.
//

import SwiftUI
import SwiftData

// MARK: - In-memory container for Previews
@MainActor
struct PreviewContainer {
    
    static let shared: ModelContainer = {
        let schema = Schema([Recipe.self, Author.self, Ingredient.self, Instruction.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            insertSampleData(into: container)
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
    
    /// Inserts sample recipes into the given container's main context.
    static func insertSampleData(into container: ModelContainer) {
        let ctx = container.mainContext
        
        // --- Recipe 1: Mie Kuah Spesial ---
        let sambalGroup = Ingredient(quantity: "", name: "Bahan Sambal Matah", groupIngredients: [
            Ingredient(quantity: "10 siung", name: "Bawang Merah"),
            Ingredient(quantity: "15 buah", name: "Cabai Rawit Merah"),
            Ingredient(quantity: "3 lembar", name: "Daun Jeruk (Buang tulang)"),
            Ingredient(quantity: "2 batang", name: "Serai (Ambil putihnya)"),
            Ingredient(quantity: "1 buah", name: "Jeruk Nipis"),
            Ingredient(quantity: "3 sdm", name: "Minyak Panas"),
        ])
        let mieIngredients: [Ingredient] = [
            sambalGroup,
            Ingredient(quantity: "1 bungkus", name: "Mie Instan Kuah"),
            Ingredient(quantity: "1 butir", name: "Telur Ayam"),
            Ingredient(quantity: "Secukupnya", name: "Sayur Sawi Hijau"),
            Ingredient(quantity: "400 ml", name: "Air"),
            Ingredient(quantity: "3 buah", name: "Cabai Rawit (Opsional)"),
        ]
        let mieInstructions: [Instruction] = [
            Instruction(sequenceNumber: 1, text: "Rebus air dalam panci hingga mendidih.", breakdownInstruction: []),
            Instruction(sequenceNumber: 2, text: "Siapkan bumbu halus.", breakdownInstruction: [
                Instruction(sequenceNumber: 1, text: "Kupas bawang merah dan bawang putih.", breakdownInstruction: []),
                Instruction(sequenceNumber: 2, text: "Ulek semua bahan bumbu bersama sejumput garam hingga halus.", breakdownInstruction: []),
                Instruction(sequenceNumber: 3, text: "Panaskan 2 sdm minyak, lalu tumis bumbu ulek tadi.", breakdownInstruction: []),
            ]),
            Instruction(sequenceNumber: 3, text: "Masukkan mie instan dan irisan cabai rawit ke dalam air rebusan.", breakdownInstruction: []),
            Instruction(sequenceNumber: 4, text: "Masak selama 1 menit.", breakdownInstruction: []),
            Instruction(sequenceNumber: 5, text: "Campurkan tumisan bumbu halus ke dalam panci mie.", breakdownInstruction: []),
            Instruction(sequenceNumber: 6, text: "Aduk rata dan sajikan selagi hangat.", breakdownInstruction: []),
        ]
        let mie = Recipe(
            title: "Mie Kuah Spesial",
            author: Author(name: "Dapur Cepat", username: "@dapurcepat"),
            portion: 1,
            durationInMinutes: 10,
            ingredients: mieIngredients,
            instructions: mieInstructions,
            tips: "Jangan merebus mie terlalu lama agar teksturnya tetap kenyal."
        )
        ctx.insert(mie)
        
        // --- Recipe 2 ---
        let ayam = Recipe(
            title: "Ayam Goreng Lengkuas",
            author: Author(name: "Dapur Nenek", username: "@dapurnenek"),
            portion: 4,
            durationInMinutes: 45,
            tips: "Goreng dengan api sedang agar matang merata."
        )
        ctx.insert(ayam)
        
        // --- Recipe 3 ---
        let sayur = Recipe(
            title: "Sayur Sop Bening",
            author: Author(name: "Masak Praktis", username: "@masakpraktis"),
            portion: 5,
            durationInMinutes: 20,
            tips: "Masukkan seledri dan daun bawang di akhir agar tetap segar."
        )
        ctx.insert(sayur)
        
        // --- Recipe 4 ---
        let telur = Recipe(
            title: "Telur Balado Spesial",
            author: Author(name: "Cita Rasa", username: "@citarasa"),
            portion: 2,
            durationInMinutes: 15,
            tips: "Gunakan cabai keriting agar tidak terlalu pedas."
        )
        ctx.insert(telur)
        
        // --- Recipe 5 ---
        let kangkung = Recipe(
            title: "Tumis Kangkung Terasi",
            author: Author(name: "Dapur Kilat", username: "@dapurkilat"),
            portion: 3,
            durationInMinutes: 10,
            tips: "Gunakan api besar saat menumis kangkung."
        )
        ctx.insert(kangkung)
        
        try? ctx.save()
    }
}
