import SwiftUI

struct AlphabetView: View {
    @State private var query = ""

    private var words: [EnochianWord] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let list = EnochianLexicon.words.sorted { $0.word < $1.word }
        guard !q.isEmpty else { return list }
        return list.filter { $0.word.lowercased().contains(q) || $0.en.lowercased().contains(q) || $0.ja.contains(q) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianBackground()
                List {
                    Section {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(Enochian.letters) { letter in
                                VStack(spacing: 4) {
                                    Text(String(letter.latin))
                                        .font(EnochianFont.swiftUI(46))
                                        .foregroundColor(Obsidian.gold)
                                        .shadow(color: Obsidian.gold.opacity(0.4), radius: 5)
                                    Text(letter.name)
                                        .font(.system(.subheadline, design: .serif).weight(.semibold))
                                        .foregroundColor(Obsidian.paleGold)
                                    Text(letter.latinLabel)
                                        .font(.caption2).foregroundColor(Obsidian.ash)
                                }
                                .frame(maxWidth: .infinity, minHeight: 112)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Obsidian.keyFace))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Obsidian.gold.opacity(0.25)))
                            }
                        }
                        .padding(.vertical, 6)
                    } header: {
                        sectionHeader(L("21の文字（ディーの表の順）", "The 21 letters (Dee's order)"))
                    }
                    .listRowBackground(Color.clear)

                    Section {
                        ForEach(words) { word in
                            HStack(spacing: 12) {
                                Text(word.word)
                                    .font(EnochianFont.swiftUI(22))
                                    .foregroundColor(Obsidian.gold)
                                    .frame(minWidth: 90, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(word.word).font(.system(.subheadline, design: .serif).weight(.semibold))
                                        .foregroundColor(Obsidian.paleGold)
                                    Text(L(word.ja, word.en))
                                        .font(.caption).foregroundColor(Obsidian.ash)
                                    if L("ja", "en") == "ja" {
                                        Text(word.en).font(.caption2.italic()).foregroundColor(Obsidian.ash.opacity(0.8))
                                    }
                                }
                            }
                            .listRowBackground(Obsidian.mirror.opacity(0.7))
                        }
                    } header: {
                        sectionHeader(L("天使の言葉（キーボードの候補に出ます）", "Angelic words (suggested by the keyboard)"))
                    }
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $query, prompt: L("言葉や意味で探す", "Search words or meanings"))
            }
            .navigationTitle(L("文字と言葉", "Letters & Words"))
            .toolbarBackground(Obsidian.black, for: .navigationBar)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.footnote.weight(.semibold)).foregroundColor(Obsidian.gold).textCase(nil)
    }
}
