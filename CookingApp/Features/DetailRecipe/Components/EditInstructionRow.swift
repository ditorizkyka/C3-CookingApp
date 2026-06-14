//
//  EditInstructionRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditInstructionRow: View {
    @Bindable var instruction: Instruction
    /// Position-based number (1, 2, 3 …) so steps always read top-to-bottom,
    /// regardless of the stored `sequenceNumber`.
    var displayNumber: Int
    var onDelete: (() -> Void)? = nil
    /// When set, the ☰ handle becomes a drag source (for live reordering).
    var onDrag: (() -> NSItemProvider)? = nil
    /// Whether the breakdown sub-steps (list + "Tambah Langkah Breakdown" button)
    /// are available. Add Manual sets this to `false`.
    var allowBreakdown: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Main Instruction Row
            HStack {
                DeleteConfirmButton {
                    onDelete?()
                }

                HStack {
                    Text("\(displayNumber)")
                        .font(.footnote)
                        .foregroundColor(Color.labelDark!)
                        .frame(width: 20, height: 20)
                        .background(Color.brandSecondary)
                        .clipShape(Circle())

                    TextField("Tulis langkah...", text: $instruction.text, axis: .vertical)
                        .font(.body)
                }

                Spacer()

                dragHandle
            }

            if allowBreakdown {
                // MARK: - Breakdown Instructions
                if !instruction.breakdownInstruction.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(instruction.breakdownInstruction) { subStep in
                            EditBreakdownInstructionRow(
                                subInstruction: subStep,
                                onDelete: {
                                    withAnimation {
                                        instruction.breakdownInstruction.removeAll { $0.id == subStep.id }
                                    }
                                }
                            )
                        }
                    }
//                    .padding(.leading, 28)
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
                    withAnimation {
                        instruction.breakdownInstruction.append(newBreakdown)
                    }
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
//                .padding(.leading, 28)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    private var dragHandle: some View {
        let handle = Image(systemName: AppIcon.line3Horizontal)
            .font(.body)
            .foregroundStyle(Color.labelLight!)

        if let onDrag {
            handle.onDrag(onDrag)
        } else {
            handle
        }
    }
}

// MARK: - Breakdown Instruction Row
struct EditBreakdownInstructionRow: View {
    @Bindable var subInstruction: Instruction
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            DeleteConfirmButton {
                onDelete?()
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
//    let container = PreviewContainer.shared
//    let ctx = container.mainContext
//    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
//    let instruction = recipes.first?.instructions.first(where: { !$0.breakdownInstruction.isEmpty })
//        ?? recipes.first?.instructions.first
//    
//    return Group {
//        if let instr = instruction {
//            @State var editableInstruction = instr
//            EditInstructionRow(instruction: $editableInstruction)
//        } else {
//            Text("No instructions in sample data")
//        }
//    }
//    .modelContainer(container)
}
