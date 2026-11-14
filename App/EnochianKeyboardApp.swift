import SwiftUI

@main
struct EnochianKeyboardApp: App {
    init() { EnochianFont.register() }

    var body: some Scene {
        WindowGroup {
            ContentView(screenshotIndex: Self.screenshotIndex)
                .preferredColorScheme(.dark)
        }
    }

    /// SCREENSHOT_MODE_1..3 launch arguments select a tab with sample content.
    private static var screenshotIndex: Int? {
        for i in 1...3 where CommandLine.arguments.contains("SCREENSHOT_MODE_\(i)") { return i }
        return nil
    }
}

struct ContentView: View {
    let screenshotIndex: Int?
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            ComposerView(sample: screenshotIndex != nil ? "MADRIAX DS PRAF" : nil)
                .tabItem { Label(L("書く", "Write"), systemImage: "pencil.and.scribble") }
                .tag(0)
            SetupView()
                .tabItem { Label(L("キーボード", "Keyboard"), systemImage: "keyboard") }
                .tag(1)
            AlphabetView()
                .tabItem { Label(L("文字と言葉", "Letters"), systemImage: "character.book.closed") }
                .tag(2)
        }
        .tint(Obsidian.gold)
        .onAppear {
            if let i = screenshotIndex { tab = [0, 2, 1][i - 1] }
        }
    }
}
