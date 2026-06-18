//
//  DeleteConfirmButton.swift
//  CookingApp
//
//  The red "minus" delete affordance used on every editable ingredient /
//  instruction row. It is the ONLY way to delete a row (no swipe-to-delete),
//  and it asks for confirmation in a popover anchored right next to the row
//  before calling `onConfirm`.
//

import SwiftUI

struct DeleteConfirmButton: View {
    /// Runs only after the user confirms the deletion.
    var onConfirm: () -> Void

    @State private var confirming = false

    var body: some View {
        Button {
            confirming = true
        } label: {
            Image(systemName: AppIcon.minusFill)
                .foregroundStyle(Color.actionDelete)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $confirming) {
            VStack(spacing: 12) {
                Text("Hapus item ini?")
                    .font(.headline)
                Text("Tindakan ini tidak dapat dibatalkan.")
                    .font(.footnote)
                    .foregroundStyle(Color.labelLight)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button(role: .cancel) {
                        confirming = false
                    } label: {
                        Text("Batal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        confirming = false
                        onConfirm()
                    } label: {
                        Text("Hapus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.actionDelete)
                }
            }
            .padding(16)
            .frame(width: 240)
            // Force a true popover (anchored to the row) on iPhone instead of a sheet.
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    DeleteConfirmButton(onConfirm: { print("deleted") })
        .padding()
}
