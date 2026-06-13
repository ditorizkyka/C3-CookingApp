//
//  ReorderDropDelegate.swift
//  CookingApp
//
//  Live drag-to-reorder for rows inside a SwiftUI `List`. Pair with `.onDrag`
//  on the ☰ handle (which sets `draggingID`) and `.onDrop(of:[.text], delegate:)`
//  on each row. The list mutates as you hover, so the move is visible in real time
//  and text fields stay editable (no system EditMode required).
//

import SwiftUI
import UniformTypeIdentifiers

struct ReorderDropDelegate<Item: Identifiable>: DropDelegate {
    let item: Item
    @Binding var items: [Item]
    @Binding var draggingID: Item.ID?
    /// Called once the drop finishes (e.g. to renumber instructions).
    var onComplete: (() -> Void)? = nil

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        guard let draggingID, draggingID != item.id,
              let from = items.firstIndex(where: { $0.id == draggingID }),
              let to = items.firstIndex(where: { $0.id == item.id })
        else { return }

        withAnimation {
            items.move(
                fromOffsets: IndexSet(integer: from),
                toOffset: to > from ? to + 1 : to
            )
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingID = nil
        onComplete?()
        return true
    }
}
