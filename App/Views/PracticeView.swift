import SwiftUI

/// The real keyboard, running inside the app so it can be tried before
/// it is turned on in Settings.
struct PracticeView: View {
    @StateObject private var model = KeyboardModel()
    var sample: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    ObsidianBackground()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            let text = Enochian.normalize(model.demoText)
                            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(L("下のキーを押してみてください。長押しで K・Y・U も打てます。単語の途中で、天使の言葉の候補が出ます。",
                                       "Tap the keys below. Long-press for K, Y and U. While you type, angelic words are suggested."))
                                    .font(.subheadline).foregroundColor(Obsidian.ash)
                            } else {
                                Text(text)
                                    .font(EnochianFont.swiftUI(46))
                                    .foregroundColor(Obsidian.gold)
                                    .shadow(color: Obsidian.gold.opacity(0.5), radius: 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(text)
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(Obsidian.paleGold)
                                ForEach(meanings(text), id: \.self) { line in
                                    Text(line).font(.footnote).foregroundColor(Obsidian.ash)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                KeyboardView(model: model)
                    .frame(height: 300)
            }
            .navigationTitle(L("キーボードを試す", "Try the Keyboard"))
            .toolbarBackground(Obsidian.black, for: .navigationBar)
            .toolbar {
                Button(L("消す", "Clear")) { model.demoText = ""; model.refresh() }
                    .disabled(model.demoText.isEmpty)
            }
            .onAppear {
                if let sample, model.demoText.isEmpty { model.demoText = sample }
                model.refresh()
            }
        }
    }

    /// "IAD = 神 (God)" for each known word.
    private func meanings(_ text: String) -> [String] {
        text.split(whereSeparator: { $0 == " " || $0 == "\n" }).compactMap { w in
            EnochianLexicon.lookup(String(w)).map { "\($0.word) = " + L("\($0.ja)（\($0.en)）", $0.en) }
        }
    }
}
