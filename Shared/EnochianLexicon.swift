import Foundation

/// Words from the Angelic Keys (Dee's 48 Claves Angelicae) used for the
/// keyboard's word suggestions and the app's word list.
struct EnochianWord: Identifiable, Hashable {
    let word: String
    let en: String
    let ja: String
    var id: String { word }
}

enum EnochianLexicon {
    static let words: [EnochianWord] = [
        .init(word: "OL", en: "I", ja: "わたし"),
        .init(word: "SONF", en: "reign", ja: "治める"),
        .init(word: "VORSG", en: "over you", ja: "あなたがたの上に"),
        .init(word: "GOHO", en: "saith", ja: "言う"),
        .init(word: "IAD", en: "God", ja: "神"),
        .init(word: "BALT", en: "justice", ja: "正義"),
        .init(word: "LANSH", en: "in power", ja: "力をもって"),
        .init(word: "CALZ", en: "firmaments", ja: "天空"),
        .init(word: "VONPHO", en: "wrath", ja: "怒り"),
        .init(word: "SOBRA", en: "whose", ja: "その"),
        .init(word: "ZOL", en: "hands", ja: "手"),
        .init(word: "ROR", en: "sun", ja: "太陽"),
        .init(word: "GRAA", en: "moon", ja: "月"),
        .init(word: "MALPRG", en: "fire", ja: "火"),
        .init(word: "PRGE", en: "fire", ja: "火"),
        .init(word: "HOLQ", en: "measured", ja: "量った"),
        .init(word: "QAA", en: "garments", ja: "衣"),
        .init(word: "NOTHOA", en: "in the midst", ja: "ただ中に"),
        .init(word: "ZIMZ", en: "vestures", ja: "衣装"),
        .init(word: "OD", en: "and", ja: "そして"),
        .init(word: "NOBLOH", en: "palms", ja: "てのひら"),
        .init(word: "ZIEN", en: "hands", ja: "手"),
        .init(word: "THIL", en: "seats", ja: "座"),
        .init(word: "OTHIL", en: "seats", ja: "座"),
        .init(word: "GNONP", en: "garnished", ja: "飾った"),
        .init(word: "ALDI", en: "gathering", ja: "集い"),
        .init(word: "DS", en: "which", ja: "それは"),
        .init(word: "VRBS", en: "beautified", ja: "美しくした"),
        .init(word: "GRSAM", en: "admiration", ja: "驚き"),
        .init(word: "TABA", en: "govern", ja: "統べる"),
        .init(word: "PIR", en: "holy ones", ja: "聖なる者たち"),
        .init(word: "CAB", en: "rod", ja: "杖"),
        .init(word: "ERM", en: "ark", ja: "箱舟"),
        .init(word: "IADNAH", en: "knowledge", ja: "知識"),
        .init(word: "ADNA", en: "obedience", ja: "従順"),
        .init(word: "GONO", en: "faith", ja: "信仰"),
        .init(word: "IADPIL", en: "him that lives", ja: "生きておられる方"),
        .init(word: "IAOD", en: "beginning", ja: "はじまり"),
        .init(word: "IPAM", en: "is not", ja: "ではない"),
        .init(word: "IPAMIS", en: "cannot be", ja: "ありえない"),
        .init(word: "LOHOLO", en: "shines", ja: "輝く"),
        .init(word: "VEP", en: "as a flame", ja: "炎のように"),
        .init(word: "POAMAL", en: "palace", ja: "宮殿"),
        .init(word: "BOGPA", en: "reigns", ja: "君臨する"),
        .init(word: "PIAP", en: "balance", ja: "天秤"),
        .init(word: "BALTOH", en: "righteousness", ja: "義"),
        .init(word: "VAOAN", en: "truth", ja: "真理"),
        .init(word: "VOOAN", en: "truth", ja: "真理"),
        .init(word: "ZACAR", en: "move", ja: "動け"),
        .init(word: "CA", en: "therefore", ja: "それゆえ"),
        .init(word: "ZAMRAN", en: "show yourselves", ja: "姿を現せ"),
        .init(word: "ODO", en: "open", ja: "開け"),
        .init(word: "CICLE", en: "mysteries", ja: "神秘"),
        .init(word: "ZORGE", en: "be friendly", ja: "親しくあれ"),
        .init(word: "ZIRDO", en: "I am", ja: "わたしはある"),
        .init(word: "ZIR", en: "I am", ja: "わたしはある"),
        .init(word: "NOCO", en: "servant", ja: "しもべ"),
        .init(word: "MAD", en: "your God", ja: "あなたがたの神"),
        .init(word: "HOATH", en: "true worshipper", ja: "まことの礼拝者"),
        .init(word: "IAIDA", en: "the Highest", ja: "いと高き方"),
        .init(word: "MICMA", en: "behold", ja: "見よ"),
        .init(word: "COMSELH", en: "circle", ja: "円"),
        .init(word: "BIAB", en: "stand", ja: "立つ"),
        .init(word: "ONDOH", en: "kingdom", ja: "王国"),
        .init(word: "NORZ", en: "six", ja: "六"),
        .init(word: "CHIS", en: "are", ja: "である"),
        .init(word: "GIGIPAH", en: "living breath", ja: "生きた息"),
        .init(word: "TELOCH", en: "death", ja: "死"),
        .init(word: "TOLT", en: "creatures", ja: "生き物"),
        .init(word: "TORZU", en: "arise", ja: "起きよ"),
        .init(word: "BALZARG", en: "stewards", ja: "執事たち"),
        .init(word: "NETAAB", en: "government", ja: "統治"),
        .init(word: "LONSA", en: "power", ja: "力"),
        .init(word: "COCASB", en: "time", ja: "時"),
        .init(word: "CAOSG", en: "earth", ja: "大地"),
        .init(word: "CAOSGA", en: "the earth", ja: "大地"),
        .init(word: "DOOIAP", en: "in the name of", ja: "の名において"),
        .init(word: "SAPAH", en: "mighty sounds", ja: "力強い響き"),
        .init(word: "VPAAH", en: "wings", ja: "翼"),
        .init(word: "ZONG", en: "winds", ja: "風"),
        .init(word: "OM", en: "understand", ja: "理解する"),
        .init(word: "FAAIP", en: "voices", ja: "声"),
        .init(word: "BIA", en: "voices", ja: "声"),
        .init(word: "SALD", en: "wonder", ja: "驚異"),
        .init(word: "IALPRG", en: "burning flames", ja: "燃える炎"),
        .init(word: "TALHO", en: "cups", ja: "杯"),
        .init(word: "PARACLEDA", en: "wedding", ja: "婚礼"),
        .init(word: "LORSLQ", en: "flowers", ja: "花"),
        .init(word: "TURBS", en: "beauty", ja: "美"),
        .init(word: "OOGE", en: "chamber", ja: "部屋"),
        .init(word: "LUSD", en: "feet", ja: "足"),
        .init(word: "MANIN", en: "mind", ja: "心"),
        .init(word: "IAIDON", en: "the All-Powerful", ja: "全能の方"),
        .init(word: "ENAY", en: "Lord", ja: "主"),
        .init(word: "APILA", en: "liveth", ja: "生きる"),
        .init(word: "QAAL", en: "creator", ja: "造り主"),
        .init(word: "QAAN", en: "creation", ja: "創造"),
        .init(word: "MOLAP", en: "sons of men", ja: "人の子ら"),
        .init(word: "UNIGLAG", en: "descend", ja: "降りよ"),
        .init(word: "PLAPLI", en: "partakers", ja: "あずかる者たち"),
        .init(word: "ANANAEL", en: "secret wisdom", ja: "秘められた知恵"),
        .init(word: "MADRIAX", en: "O ye heavens", ja: "おお、天よ"),
        .init(word: "PIRIPSOL", en: "heavens", ja: "天"),
        .init(word: "LUCAL", en: "north", ja: "北"),
        .init(word: "BABAGE", en: "south", ja: "南"),
    ]

    /// Up to `limit` words starting with the given (Latin) prefix.
    static func suggestions(for prefix: String, limit: Int = 6) -> [EnochianWord] {
        let p = prefix.uppercased()
        guard !p.isEmpty else { return [] }
        var seen = Set<String>()
        return words
            .filter { $0.word.hasPrefix(p) && $0.word != p && seen.insert($0.word).inserted }
            .sorted { $0.word.count < $1.word.count }
            .prefix(limit)
            .map { $0 }
    }

    static func lookup(_ word: String) -> EnochianWord? {
        words.first { $0.word == word.uppercased() }
    }
}
