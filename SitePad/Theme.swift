import SwiftUI

enum Theme {
    static let steel = Color(hex: 0x14181C)
    static let surface = Color(hex: 0xF2F2EF)
    static let card = Color(hex: 0xFFFFFF)
    static let rule = Color(hex: 0xD6D6D0)
    static let amber = Color(hex: 0xE8A200)
    static let green = Color(hex: 0x1F7A4D)
    static let red = Color(hex: 0xB23A2E)
    static let muted = Color(hex: 0x6E7378)
    static let disabled = Color(hex: 0xC4C6C3)
    static let dimText = Color(white: 0.65)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
