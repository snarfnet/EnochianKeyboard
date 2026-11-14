import UIKit
import SwiftUI
import CoreText

enum EnochianFont {
    private static var registered = false

    /// Registers the bundled font for the current process (app or keyboard extension).
    static func register() {
        guard !registered else { return }
        registered = true
        guard let url = Bundle.main.url(forResource: Enochian.fontName, withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func ui(_ size: CGFloat) -> UIFont {
        register()
        return UIFont(name: Enochian.fontName, size: size) ?? .systemFont(ofSize: size)
    }

    static func swiftUI(_ size: CGFloat) -> Font {
        register()
        return .custom(Enochian.fontName, fixedSize: size)
    }
}

/// Color schemes for exported images.
enum GlyphStyle: String, CaseIterable, Identifiable {
    case obsidian, parchment, stencil, glowWhite, inkBlack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .obsidian: return L("黒鏡と金", "Obsidian & Gold")
        case .parchment: return L("羊皮紙", "Parchment")
        case .stencil: return L("タトゥー下絵", "Tattoo Stencil")
        case .glowWhite: return L("白（透明）", "White, Clear")
        case .inkBlack: return L("黒（透明）", "Black, Clear")
        }
    }

    var ink: UIColor {
        switch self {
        case .obsidian: return UIColor(red: 0.93, green: 0.78, blue: 0.42, alpha: 1)
        case .parchment: return UIColor(red: 0.30, green: 0.16, blue: 0.08, alpha: 1)
        case .stencil, .inkBlack: return .black
        case .glowWhite: return .white
        }
    }

    /// nil = transparent background
    var background: UIColor? {
        switch self {
        case .obsidian: return UIColor(red: 0.05, green: 0.04, blue: 0.06, alpha: 1)
        case .parchment: return UIColor(red: 0.91, green: 0.84, blue: 0.69, alpha: 1)
        case .stencil: return .white
        case .glowWhite, .inkBlack: return nil
        }
    }

    var glows: Bool { self == .obsidian || self == .glowWhite }
}

enum GlyphRenderer {
    /// Renders Enochian text (Latin input, drawn with the Enochian font) to an image.
    /// - canvas: fixed output size (e.g. a wallpaper); nil = fit the text with padding.
    static func image(text: String, style: GlyphStyle, rightToLeft: Bool,
                      fontSize: CGFloat = 120, canvas: CGSize? = nil,
                      showNames: Bool = false) -> UIImage? {
        let normalized = Enochian.normalize(text).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        let display = rightToLeft ? Enochian.rightToLeft(normalized) : normalized

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = fontSize * 0.25

        var attrs: [NSAttributedString.Key: Any] = [
            .font: EnochianFont.ui(fontSize),
            .foregroundColor: style.ink,
            .paragraphStyle: paragraph,
            .kern: fontSize * 0.12,
        ]
        if style.glows {
            let shadow = NSShadow()
            shadow.shadowColor = style.ink.withAlphaComponent(0.85)
            shadow.shadowBlurRadius = fontSize * 0.18
            shadow.shadowOffset = .zero
            attrs[.shadow] = shadow
        }
        let glyphs = NSAttributedString(string: display, attributes: attrs)

        var caption: NSAttributedString?
        if showNames {
            let capPara = NSMutableParagraphStyle()
            capPara.alignment = .center
            caption = NSAttributedString(string: normalized.replacingOccurrences(of: "\n", with: "  "), attributes: [
                .font: UIFont(name: "Georgia", size: fontSize * 0.22) ?? .systemFont(ofSize: fontSize * 0.22),
                .foregroundColor: style.ink.withAlphaComponent(0.7),
                .paragraphStyle: capPara,
                .kern: fontSize * 0.06,
            ])
        }

        let maxWidth = (canvas?.width ?? 4000) - fontSize
        let glyphSize = glyphs.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                            options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral.size
        let captionSize = caption?.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                options: [.usesLineFragmentOrigin], context: nil).integral.size ?? .zero
        let gap = caption == nil ? 0 : fontSize * 0.35
        let contentHeight = glyphSize.height + gap + captionSize.height
        let pad = fontSize * 0.5
        let size = canvas ?? CGSize(width: max(glyphSize.width, captionSize.width) + pad * 2,
                                    height: contentHeight + pad * 2)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = style.background != nil
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            if let bg = style.background {
                bg.setFill()
                ctx.fill(CGRect(origin: .zero, size: size))
            }
            let top = (size.height - contentHeight) / 2
            glyphs.draw(with: CGRect(x: (size.width - maxWidth) / 2, y: top, width: maxWidth, height: glyphSize.height),
                        options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            caption?.draw(with: CGRect(x: (size.width - maxWidth) / 2, y: top + glyphSize.height + gap,
                                       width: maxWidth, height: captionSize.height),
                          options: [.usesLineFragmentOrigin], context: nil)
        }
    }
}

/// Japanese when the device prefers Japanese, otherwise English.
func L(_ ja: String, _ en: String) -> String {
    (Locale.preferredLanguages.first ?? "en").hasPrefix("ja") ? ja : en
}
