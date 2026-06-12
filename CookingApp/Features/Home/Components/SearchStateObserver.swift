import SwiftUI

struct SearchStateObserver: View {
    @Environment(\.isSearching) var isSearching
    @Binding var isSearchActive: Bool
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: isSearching) { _, newValue in
                isSearchActive = newValue
            }
    }
}
