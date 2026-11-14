import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    private let model = KeyboardModel()
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        EnochianFont.register()
        model.controller = self

        let host = UIHostingController(rootView: KeyboardView(model: model))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)

        let height = view.heightAnchor.constraint(equalToConstant: 300)
        height.priority = .defaultHigh
        height.isActive = true
        heightConstraint = height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.refresh()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        model.refresh()
    }
}

final class KeyboardModel: ObservableObject {
    weak var controller: UIInputViewController?

    /// Text on the current line before the cursor.
    @Published var phrase = ""
    /// The word being typed (letters after the last space).
    @Published var partial = ""
    @Published var copied = false
    @Published var showsGlobe = true
    @Published var hasFullAccess = false

    private var proxy: UITextDocumentProxy? { controller?.textDocumentProxy }

    func refresh() {
        let before = proxy?.documentContextBeforeInput ?? ""
        let line = before.split(separator: "\n", omittingEmptySubsequences: false).last.map(String.init) ?? ""
        phrase = line
        partial = line.split(separator: " ", omittingEmptySubsequences: false).last.map(String.init) ?? ""
        showsGlobe = controller?.needsInputModeSwitchKey ?? true
        hasFullAccess = controller?.hasFullAccess ?? false
    }

    func insert(_ text: String) {
        proxy?.insertText(text)
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
        proxy?.deleteBackward()
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
