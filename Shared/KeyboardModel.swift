import UIKit

final class KeyboardModel: ObservableObject {
    weak var controller: UIInputViewController?

    /// Text on the current line before the cursor.
    @Published var phrase = ""
    /// The word being typed (letters after the last space).
    @Published var partial = ""
    @Published var copied = false
    @Published var showsGlobe = true
    @Published var hasFullAccess = false

    /// Without a controller (the in-app practice screen) typing goes here.
    @Published var demoText = ""

    private var proxy: UITextDocumentProxy? { controller?.textDocumentProxy }

    func refresh() {
        let before = controller == nil ? demoText : (proxy?.documentContextBeforeInput ?? "")
        let line = before.split(separator: "\n", omittingEmptySubsequences: false).last.map(String.init) ?? ""
        phrase = line
        partial = line.split(separator: " ", omittingEmptySubsequences: false).last.map(String.init) ?? ""
        showsGlobe = controller?.needsInputModeSwitchKey ?? false
        hasFullAccess = controller?.hasFullAccess ?? true
    }

    func insert(_ text: String) {
        if controller == nil { demoText += text } else { proxy?.insertText(text) }
        refresh()
    }

    func type(_ letter: EnochianLetter, alternate: Bool = false) {
        let c = alternate ? (letter.alternates.first ?? letter.latin) : letter.latin
        insert(String(c))
    }

    func complete(_ word: EnochianWord) {
        let rest = word.word.dropFirst(partial.count)
        insert(String(rest) + " ")
    }

    func deleteBackward() {
        if controller == nil { if !demoText.isEmpty { demoText.removeLast() } } else { proxy?.deleteBackward() }
        refresh()
    }

    func newline() { insert("\n") }

    func nextKeyboard() { controller?.advanceToNextInputMode() }

    /// Copies the current line as an Enochian image (needs Full Access).
    func copyImage() {
        guard hasFullAccess,
              let image = GlyphRenderer.image(text: phrase, style: .obsidian, rightToLeft: false, fontSize: 96)
        else { return }
        UIPasteboard.general.image = image
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { self.copied = false }
    }
}
