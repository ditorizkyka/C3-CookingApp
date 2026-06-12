//
//  EditInstructionRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditInstructionRow: View {
    @Binding var instruction: Instruction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Main Instruction Row
            HStack {
                Button {
                    print("deleted instruction")
                } label: {
                    Image(systemName: AppIcon.minusFill)
                        .foregroundStyle(Color.actionDelete!)
                }
                
                HStack {
                    Text("\(instruction.sequenceNumber)")
                        .font(.footnote)
                        .foregroundColor(Color.labelDark!)
                        .frame(width: 20, height: 20)
                        .background(Color.brandSecondary)
                        .clipShape(Circle())
                    
                    TextField("Tulis langkah...", text: $instruction.text, axis: .vertical)
                        .font(.body)
                }
                
                Spacer()
                
                Image(systemName: AppIcon.line3Horizontal)
                    .font(.body)
                    .foregroundStyle(Color.labelLight!)
            }
            
            // MARK: - Breakdown Instructions
            if !instruction.breakdownInstruction.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach($instruction.breakdownInstruction) { $subStep in
                        EditBreakdownInstructionRow(subInstruction: $subStep)
                    }
                }
//                .padding(.leading, 28)
                .padding(.top, 8)
            }
            
            // MARK: - Tambah Langkah Breakdown
            Button {
                let newBreakdown = Instruction(
                    id: UUID(),
                    sequenceNumber: instruction.breakdownInstruction.count + 1,
                    text: "",
                    photoUrl: nil,
                    breakdownInstruction: []
                )
                instruction.breakdownInstruction.append(newBreakdown)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: AppIcon.plusFill)
                        .foregroundStyle(Color.brandPrimary!)
                    Text("Tambah Langkah Breakdown")
                        .font(.body)
                        .foregroundStyle(Color.brandPrimary!)
                }
            }
            .buttonStyle(.plain)
//            .padding(.leading, 28)
            .padding(.top, 12)
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Breakdown Instruction Row
struct EditBreakdownInstructionRow: View {
    @Binding var subInstruction: Instruction
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                print("deleted breakdown instruction")
            } label: {
                Image(systemName: AppIcon.minusFill)
                    .foregroundStyle(Color.actionDelete!)
            }
            
            Circle()
                .fill(Color.labelDark!)
                .frame(width: 3, height: 3)
                .padding(.horizontal,10)
            
            TextField("Tulis sub-langkah...", text: $subInstruction.text, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(Color.labelLight!)
            
            Spacer()
            
            Image(systemName: AppIcon.line3Horizontal)
                .font(.body)
                .foregroundStyle(Color.labelLight!)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Photo Picker
struct PhotoPickerHStack: View {
  
    @State private var selectedImage: Image? = Image("image_preview")

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    
                    (selectedImage ?? Image(systemName: "person.crop.circle.fill"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color.labelLight!)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    
                    if selectedImage != nil {
                        Button(action: {
                            withAnimation {
                                selectedImage = nil
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.caption2.bold())
                                .foregroundColor(Color.labelLightest!)
                                .padding(8)
                                .background(Color.actionDelete!)
                                .clipShape(Circle())
                        }
                        .offset(x: 10, y: -10)
                    }
                }
                .frame(width: 100, height: 100)
                
                Button(action: {
                    print("Tombol Tambah Foto ditekan")
                }) {
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(Color.labelLight!)
                            
                            Image(systemName: AppIcon.plusFill)
                                .font(.title3)
                                .foregroundColor(Color.labelLight!)
                                .background(Color.surfaceElevated!)
                                .clipShape(Circle())
                                .offset(x: 5, y: 5)
                        }
                        
                        Text("Tambah Foto")
                            .font(.caption)
                            .foregroundColor(Color.labelLight!)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.surfaceElevated!)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.small)
                            .stroke(Color.labelLight!, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
                .buttonStyle(.plain)
            }
     
            .padding(.top, 12)
            .padding(.trailing, 12)
            .padding(.bottom, 8)
            .padding(.leading, 4)
        }
        
    }
}

#Preview {
    @Previewable @State var instruction = Recipe.dummyRecipes[0].instructions[1]
    EditInstructionRow(instruction: $instruction)
}
