import SwiftUI

enum ExportSize: String, CaseIterable, Identifiable {
    case fit, wallpaper, square
    var id: String { rawValue }

    var title: String {
        switch self {
        case .fit: return L("文字に合わせる", "Fit text")
        case .wallpaper: return L("壁紙", "Wallpaper")
        case .square: return L("正方形", "Square")
        }
    }

    var canvas: CGSize? {
        switch self {
        case .fit: return nil
        case .wallpaper: return CGSize(width: 1290, height: 2796)
        case .square: return CGSize(width: 2048, height: 2048)
        }
    }
}

struct ComposerView: View {
    @State private var text: String
    @State private var style: GlyphStyle = .obsidian
    @State private var rightToLeft = false
    @State private var showNames = true
    @State private var size: ExportSize = .fit
    @State private var shareImage: ShareItem?
    @FocusState private var editing: Bool

    init(sample: String? = nil) {
        _text = State(initialValue: sample ?? "")
    }

    private var normalized: String { Enochian.normalize(text).trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        input
                        preview
                        options
                        exportButtons
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(L("エノク文字で書く", "Write in Enochian"))
            .toolbarBackground(Obsidian.black, for: .navigationBar)
            .sheet(item: $shareImage) { ShareSheet(items: [$0.image]) }
        }
    }

    private var input: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("ローマ字で入力（名前・言葉）", "Type in Latin letters (a name or a word)"))
                .font(.footnote).foregroundColor(Obsidian.ash)
            TextField(L("例：MICHAEL、SAKURA", "e.g. MICHAEL, LUCAL"), text: $text, axis: .vertical)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($editing)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(Obsidian.paleGold)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Obsidian.mirror))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Obsidian.gold.opacity(0.4)))
            if !normalized.isEmpty {
                Text(Enochian.spelledNames(normalized))
                    .font(.caption).foregroundColor(Obsidian.ash)
            }
        }
    }

    private var preview: some View {
        Group {
            if let image = GlyphRenderer.image(text: text, style: style, rightToLeft: rightToLeft,
                                               fontSize: 120, canvas: size.canvas, showNames: showNames) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: size == .wallpaper ? 420 : 300)
                    .background(CheckerBoard().opacity(style.background == nil ? 1 : 0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Obsidian.gold.opacity(0.3)))
            } else {
                VStack(spacing: 10) {
                    Text("MADRIAX").font(EnochianFont.swiftUI(54)).foregroundColor(Obsidian.gold.opacity(0.35))
                    Text(L("ここに天使の文字が現れます", "The angelic script appears here"))
                        .font(.footnote).foregroundColor(Obsidian.ash)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .goldCard()
            }
        }
    }

    private var options: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GlyphStyle.allCases) { s in
                        Button { style = s } label: {
                            Text(s.title)
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(style == s ? Obsidian.black : Obsidian.paleGold)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(Capsule().fill(style == s ? Obsidian.gold : Obsidian.keyFace))
                        }
                    }
                }
            }
            Picker(L("サイズ", "Size"), selection: $size) {
                ForEach(ExportSize.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Toggle(L("右から左に書く（ディーの原本の向き）", "Right to left (as in Dee's manuscripts)"), isOn: $rightToLeft)
            Toggle(L("下にローマ字を添える", "Add Latin letters below"), isOn: $showNames)
        }
        .font(.subheadline)
        .foregroundColor(Obsidian.paleGold)
        .tint(Obsidian.gold)
        .goldCard()
    }

    private var exportButtons: some View {
        Button {
            editing = false
            if let image = GlyphRenderer.image(text: text, style: style, rightToLeft: rightToLeft,
                                               fontSize: size == .fit ? 220 : 160, canvas: size.canvas,
                                               showNames: showNames) {
                shareImage = ShareItem(image: image)
            }
        } label: {
            Label(L("画像を保存・共有", "Save or share image"), systemImage: "square.and.arrow.up")
                .font(.headline)
                .foregroundColor(Obsidian.black)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(Obsidian.gold))
        }
        .disabled(normalized.isEmpty)
        .opacity(normalized.isEmpty ? 0.4 : 1)
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// Shows transparency behind clear-background styles.
struct CheckerBoard: View {
    var body: some View {
        Canvas { ctx, size in
            let cell: CGFloat = 12
            for y in stride(from: 0, to: size.height, by: cell) {
                for x in stride(from: 0, to: size.width, by: cell) where (Int(x / cell) + Int(y / cell)).isMultiple(of: 2) {
                    ctx.fill(Path(CGRect(x: x, y: y, width: cell, height: cell)), with: .color(.gray.opacity(0.35)))
                }
            }
        }
        .background(Color.gray.opacity(0.15))
    }
}
