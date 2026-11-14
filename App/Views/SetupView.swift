import SwiftUI

struct SetupView: View {
    @State private var testText = ""

    private let steps: [(String, String)] = [
        ("「設定」アプリを開く（下のボタンでも開けます）", "Open the Settings app (or tap the button below)"),
        ("一般 ＞ キーボード ＞ キーボード ＞ 新しいキーボードを追加", "General › Keyboard › Keyboards › Add New Keyboard"),
        ("「エノク文字キーボード」を選ぶ", "Choose \"Enochian Keyboard\""),
        ("文字を打つときに 🌐 を押して切り替える", "Tap 🌐 while typing to switch to it"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        stepsCard
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label(L("設定を開く", "Open Settings"), systemImage: "gearshape")
                                .font(.headline).foregroundColor(Obsidian.black)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Obsidian.gold))
                        }
                        fullAccessCard
                        tryCard
                        aboutCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle(L("キーボードの準備", "Set Up the Keyboard"))
            .toolbarBackground(Obsidian.black, for: .navigationBar)
        }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(steps.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(i + 1)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Obsidian.black)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Obsidian.gold))
                    Text(L(steps[i].0, steps[i].1))
                        .font(.subheadline).foregroundColor(Obsidian.paleGold)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .goldCard()
    }

    private var fullAccessCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L("「画像でコピー」を使うには", "To use \"Copy image\""), systemImage: "photo.on.rectangle")
                .font(.headline).foregroundColor(Obsidian.gold)
            Text(L("エノク文字は世界共通の文字コードにまだ入っていません。キーボードはローマ字を打ちながら、上の帯にエノク文字を表示します。LINE や Instagram にエノク文字のまま送りたいときは「画像でコピー」を押して貼り付けてください。このボタンは、設定のキーボード画面で「フルアクセスを許可」をオンにすると現れます。",
                   "Enochian is not yet part of Unicode, so the keyboard types Latin letters and shows the angelic script in the bar above the keys. To send the script itself to Messages, LINE or Instagram, tap \"Copy image\" and paste. The button appears after you turn on \"Allow Full Access\" in the keyboard's settings."))
                .font(.footnote).foregroundColor(Obsidian.paleGold)
            Text(L("フルアクセスは画像をクリップボードに入れるためだけに使います。打った文字を記録したり、外へ送ったりはしません。このアプリはネットにつながりません。",
                   "Full Access is used only to put the image on the clipboard. Nothing you type is stored or sent anywhere, and the app never connects to the internet."))
                .font(.footnote).foregroundColor(Obsidian.ash)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .goldCard()
    }

    private var tryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("ここで試し打ち", "Try it here"))
                .font(.headline).foregroundColor(Obsidian.gold)
            TextField(L("🌐 でエノク文字キーボードに切り替え", "Switch to the Enochian keyboard with 🌐"), text: $testText, axis: .vertical)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Obsidian.black))
                .foregroundColor(Obsidian.paleGold)
            if !Enochian.normalize(testText).isEmpty {
                Text(Enochian.normalize(testText))
                    .font(EnochianFont.swiftUI(34))
                    .foregroundColor(Obsidian.gold)
                    .shadow(color: Obsidian.gold.opacity(0.5), radius: 6)
            }
        }
        .goldCard()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("エノク文字とは", "About the script"))
                .font(.headline).foregroundColor(Obsidian.gold)
            Text(L("1580年代、エリザベス1世の宮廷学者ジョン・ディーと霊媒エドワード・ケリーが「天使から授かった」と記録した21の文字です。ディーの手稿（大英図書館 Sloane MS 3188）に表が残っています。キーボードの字形はこの表をもとに作りました。",
                   "Twenty-one letters that John Dee, scholar at the court of Elizabeth I, and the scryer Edward Kelley recorded in the 1580s as received from angels. Dee's table survives in his manuscripts (British Library, Sloane MS 3188); the keyboard's glyphs are drawn from it."))
                .font(.footnote).foregroundColor(Obsidian.paleGold)
        }
        .goldCard()
    }
}
