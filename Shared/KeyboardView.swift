import SwiftUI

struct KeyboardView: View {
    @ObservedObject var model: KeyboardModel

    var body: some View {
        VStack(spacing: 6) {
            topBar
            ForEach(Enochian.keyboardRows.indices, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(Enochian.keyboardRows[row]) { letter in
                        LetterKey(letter: letter) { model.type(letter, alternate: $0) }
                    }
                }
            }
            bottomRow
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Obsidian.black)
    }

    // MARK: Preview + suggestions

    private var topBar: some View {
        HStack(spacing: 6) {
            let suggestions = EnochianLexicon.suggestions(for: model.partial, limit: 4)
            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions) { word in
                            Button { model.complete(word) } label: {
                                VStack(spacing: 0) {
                                    Text(word.word).font(EnochianFont.swiftUI(17)).foregroundColor(Obsidian.gold)
                                    Text("\(word.word) · \(L(word.ja, word.en))")
                                        .font(.system(size: 9)).foregroundColor(Obsidian.ash).lineLimit(1)
                                }
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(Obsidian.keyFace))
                            }
                        }
                    }
                }
            } else {
                let shown = Enochian.normalize(model.phrase)
                Text(shown.isEmpty ? " " : String(shown.suffix(28)))
                    .font(EnochianFont.swiftUI(22))
                    .foregroundColor(Obsidian.gold)
                    .shadow(color: Obsidian.gold.opacity(0.6), radius: 4)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 6)
                    .overlay(alignment: .leading) {
                        if shown.isEmpty {
                            Text(L("天使の文字で入力", "Type in the angelic script"))
                                .font(.system(size: 12)).foregroundColor(Obsidian.ash).padding(.leading, 6)
                        }
                    }
            }
            copyButton
        }
        .frame(height: 40)
    }

    @ViewBuilder private var copyButton: some View {
        if model.hasFullAccess {
            Button(action: model.copyImage) {
                Label(model.copied ? L("コピー済み", "Copied") : L("画像でコピー", "Copy image"),
                      systemImage: model.copied ? "checkmark" : "photo.on.rectangle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Obsidian.black)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Capsule().fill(Obsidian.gold))
            }
            .disabled(Enochian.normalize(model.phrase).trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: Bottom row

    private var bottomRow: some View {
        HStack(spacing: 5) {
            if model.showsGlobe {
                SystemKey(systemImage: "globe", width: 44) { model.nextKeyboard() }
            }
            SystemKey(label: ".", width: 40) { model.insert(".") }
            Button { model.insert(" ") } label: {
                Text(L("空白", "space"))
                    .font(.system(size: 15)).foregroundColor(Obsidian.paleGold)
                    .frame(maxWidth: .infinity, minHeight: 42)
                    .background(RoundedRectangle(cornerRadius: 7).fill(Obsidian.keyFace))
            }
            DeleteKey { model.deleteBackward() }
            SystemKey(systemImage: "return", width: 52) { model.newline() }
        }
    }
}

struct LetterKey: View {
    let letter: EnochianLetter
    let onType: (_ alternate: Bool) -> Void
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 1) {
            Text(String(letter.latin))
                .font(EnochianFont.swiftUI(24))
                .foregroundColor(Obsidian.paleGold)
            Text(letter.alternates.isEmpty ? String(letter.latin) : letter.latinLabel.replacingOccurrences(of: " ", with: ""))
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Obsidian.ash)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, minHeight: 46)
        .background(RoundedRectangle(cornerRadius: 7).fill(pressed ? Obsidian.keyEdge : Obsidian.keyFace))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Obsidian.gold.opacity(0.18), lineWidth: 0.5))
        .contentShape(Rectangle())
        .onTapGesture { onType(false) }
        // Long press types the alternate value (C→K, I→Y, V→U).
        .onLongPressGesture(minimumDuration: 0.4, pressing: { pressed = $0 }) {
            onType(true)
        }
        .accessibilityLabel("\(letter.name), \(letter.latinLabel)")
    }
}

struct SystemKey: View {
    var label: String? = nil
    var systemImage: String? = nil
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage { Image(systemName: systemImage) } else { Text(label ?? "") }
            }
            .font(.system(size: 17))
            .foregroundColor(Obsidian.paleGold)
            .frame(width: width, height: 42)
            .background(RoundedRectangle(cornerRadius: 7).fill(Obsidian.mirror))
        }
    }
}

/// Deletes once on touch, then repeats while held.
struct DeleteKey: View {
    let action: () -> Void
    @State private var timer: Timer?

    var body: some View {
        Image(systemName: "delete.left")
            .font(.system(size: 17))
            .foregroundColor(Obsidian.paleGold)
            .frame(width: 52, height: 42)
            .background(RoundedRectangle(cornerRadius: 7).fill(timer == nil ? Obsidian.mirror : Obsidian.keyEdge))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard timer == nil else { return }
                    action()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { _ in
                        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in action() }
                    }
                }
                .onEnded { _ in
                    timer?.invalidate()
                    timer = nil
                })
            .accessibilityLabel(L("削除", "Delete"))
    }
}
