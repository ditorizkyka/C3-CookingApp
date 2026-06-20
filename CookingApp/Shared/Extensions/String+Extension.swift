import Foundation

extension String {
    func removingEmojis() -> String {
        return self.unicodeScalars.filter { !$0.properties.isEmojiPresentation }.map(String.init).joined()
    }
}
