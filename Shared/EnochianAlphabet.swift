import Foundation

/// One of the 21 letters of Dee's angelic alphabet.
/// `latin` is the letter the keyboard inserts; the bundled font draws
/// the Enochian glyph for that Latin code point (and for its alternates).
struct EnochianLetter: Identifiable, Hashable {
    let name: String
    let latin: Character
    let alternates: [Character]
    var id: String { name }

    /// "A", "C / K", "I / Y / J" ...
    var latinLabel: String {
        ([latin] + alternates).map(String.init).joined(separator: " / ")
    }
}

enum Enochian {
    static let fontName = "EnochianDee"

    /// Order of Dee's table (Sloane MS 3188): Pa, Veh, Ged, Gal, Or, Un, Graph,
    /// Tal, Gon, Na, Ur, Mals, Ger, Drux, Pal, Med, Don, Ceph, Van, Fam, Gisg.
    static let letters: [EnochianLetter] = [
        .init(name: "Pa", latin: "B", alternates: []),
        .init(name: "Veh", latin: "C", alternates: ["K"]),
        .init(name: "Ged", latin: "G", alternates: []),
        .init(name: "Gal", latin: "D", alternates: []),
        .init(name: "Or", latin: "F", alternates: []),
        .init(name: "Un", latin: "A", alternates: []),
        .init(name: "Graph", latin: "E", alternates: []),
        .init(name: "Tal", latin: "M", alternates: []),
        .init(name: "Gon", latin: "I", alternates: ["Y", "J"]),
        .init(name: "Na", latin: "H", alternates: []),
        .init(name: "Ur", latin: "L", alternates: []),
        .init(name: "Mals", latin: "P", alternates: []),
        .init(name: "Ger", latin: "Q", alternates: []),
        .init(name: "Drux", latin: "N", alternates: []),
        .init(name: "Pal", latin: "X", alternates: []),
        .init(name: "Med", latin: "O", alternates: []),
        .init(name: "Don", latin: "R", alternates: []),
        .init(name: "Ceph", latin: "Z", alternates: []),
        .init(name: "Van", latin: "V", alternates: ["U", "W"]),
        .init(name: "Fam", latin: "S", alternates: []),
        .init(name: "Gisg", latin: "T", alternates: []),
    ]

    /// Keyboard layout: three rows of seven, in alphabetical (Latin) order
    /// so people who know the Latin values can find keys quickly.
    static let keyboardRows: [[EnochianLetter]] = {
        let sorted = letters.sorted { $0.latin < $1.latin }
        return stride(from: 0, to: sorted.count, by: 7).map { Array(sorted[$0..<min($0 + 7, sorted.count)]) }
    }()

    static func letter(for character: Character) -> EnochianLetter? {
        let c = Character(character.uppercased())
        return letters.first { $0.latin == c || $0.alternates.contains(c) }
    }

    /// Keeps only characters the font can draw (letters with an Enochian
    /// equivalent, spaces and line breaks), uppercased.
    static func normalize(_ text: String) -> String {
        String(text.uppercased().filter { $0 == " " || $0 == "\n" || letter(for: $0) != nil })
    }

    /// Dee wrote the angelic script from right to left. Reverses each line.
    static func rightToLeft(_ text: String) -> String {
        text.split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0.reversed()) }
            .joined(separator: "\n")
    }

    /// "MADRIAX" -> "Tal · Un · Gal · Don · Gon · Un · Pal"
    static func spelledNames(_ text: String) -> String {
        normalize(text).compactMap { letter(for: $0)?.name }.joined(separator: " · ")
    }
}
