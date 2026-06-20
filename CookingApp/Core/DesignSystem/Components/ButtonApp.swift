import SwiftUI

// 1. Buat Enum untuk mendefinisikan jenis tombol
enum ButtonStyleType {
    case primary
    case secondary
    case tertiary
}

struct ButtonApp: View {
    var title: String = "Button Native"
    var iconButton: String? = nil
    var type: ButtonStyleType = .primary
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 12) {
                
                
                Text(title)
                    .font(.headline)
                if let icon = iconButton {
                    Image(systemName: icon)
                }
            }
            
            .foregroundColor(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(25)
            
        }
    }
    
    // MARK: - Computed Properties untuk Logika Warna
    
    private var textColor: Color {
        switch type {
        case .primary:
            return .white
        case .secondary:
            return .black
        case .tertiary:
            return .gray
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .primary:
            return .brandAccent
        case .secondary:
            return Color(UIColor.systemGray5)
        case .tertiary:
            return .clear
        }
    }
}

// MARK: - Preview
struct ButtonApp_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            
            // 1. Primary dengan Icon
            ButtonApp(title: "Tambah Item", iconButton: "plus", type: .primary, action: {
                print("Primary Icon ditekan")
            })
            
            // 2. Primary tanpa Icon
            ButtonApp(title: "Simpan", type: .primary, action: {
                print("Primary ditekan")
            })
            
            // 3. Secondary
            ButtonApp(title: "Cancel", type: .secondary, action: {
                print("Secondary ditekan")
            })
            
            // 4. Tertiary
            ButtonApp(title: "Coba Nanti", type: .tertiary, action: {
                print("Tertiary ditekan")
            })
            
        }
        .padding()
    }
}
