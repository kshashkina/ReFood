import SwiftUI

extension Color {
    static let appAccent = Color(red: 144/255, green: 240/255, blue: 71/255)
    static let appGlass = Color.white.opacity(0.05)
    static let appError = Color.red
    static func grade(_ letter: String) -> Color {
        switch letter.lowercased() {
        case "a": return Color(red: 144/255, green: 240/255, blue: 71/255)
        case "b": return Color(red: 179/255, green: 243/255, blue: 87/255)
        case "c": return Color(red: 245/255, green: 221/255, blue: 77/255)
        case "d": return Color(red: 255/255, green: 163/255, blue: 62/255)
        case "e": return Color(red: 255/255, green: 84/255,  blue: 84/255)
        default: return Color.white.opacity(0.45)
        }
    }
}
