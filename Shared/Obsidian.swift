import SwiftUI

/// Dee's black scrying mirror and gold ink.
enum Obsidian {
    static let black = Color(red: 0.035, green: 0.03, blue: 0.045)
    static let mirror = Color(red: 0.09, green: 0.08, blue: 0.11)
    static let keyFace = Color(red: 0.14, green: 0.12, blue: 0.16)
    static let keyEdge = Color(red: 0.30, green: 0.25, blue: 0.20)
    static let gold = Color(red: 0.93, green: 0.78, blue: 0.42)
    static let paleGold = Color(red: 0.98, green: 0.92, blue: 0.75)
    static let ash = Color(red: 0.62, green: 0.58, blue: 0.55)
    static let ember = Color(red: 0.75, green: 0.32, blue: 0.20)
}

struct ObsidianBackground: View {
    var body: some View {
        ZStack {
            Obsidian.black
            RadialGradient(colors: [Obsidian.mirror, Obsidian.black],
                           center: .init(x: 0.5, y: 0.3), startRadius: 10, endRadius: 520)
            RadialGradient(colors: [Obsidian.gold.opacity(0.10), .clear],
                           center: .init(x: 0.5, y: 0.0), startRadius: 0, endRadius: 360)
        }
        .ignoresSafeArea()
    }
}

extension View {
    func goldCard() -> some View {
        padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(Obsidian.mirror.opacity(0.9)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Obsidian.gold.opacity(0.35), lineWidth: 1))
    }
}
