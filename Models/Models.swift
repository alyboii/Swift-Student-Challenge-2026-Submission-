import SwiftUI

// MARK: - Product

struct Product: Identifiable, Sendable, Codable {
    let id = UUID()
    let name: String         // Turkish name: "Simit"
    let englishName: String  // English subtitle: "Sesame Ring"
    let emoji: String
    let price: Int           // in Canteen Coins 🪙

    // id is auto-generated for Identifiable only — exclude from Codable
    enum CodingKeys: String, CodingKey {
        case name, englishName, emoji, price
    }

    static let menu: [Product] = [
        Product(name: "Simit",    englishName: "Sesame Ring",      emoji: "🥯", price: 5),
        Product(name: "Ayran",    englishName: "Yogurt Drink",     emoji: "🥛", price: 3),
        Product(name: "Tost",     englishName: "Grilled Sandwich", emoji: "🥪", price: 10),
        Product(name: "Poğaça",  englishName: "Pastry",           emoji: "🧆", price: 7),
        Product(name: "Water",     englishName: "Still Water",      emoji: "💧", price: 1),
        Product(name: "Chocolate", englishName: "Chocolate Bar",    emoji: "🍫", price: 8),
    ]

    var accentColor: Color {
        switch name {
        case "Simit":    return Color.simitSarisi
        case "Ayran":    return Color(red: 0.55, green: 0.75, blue: 0.90)
        case "Tost":     return Color.tostTuruncusu
        case "Water":     return Color(red: 0.40, green: 0.72, blue: 0.92)  // Light blue
        case "Chocolate": return Color(red: 0.44, green: 0.27, blue: 0.14)  // Chocolate brown
        default:         return Color(red: 0.75, green: 0.60, blue: 0.45)
        }
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, CaseIterable, Identifiable, Sendable {
    case easy   = "Easy"
    case medium = "Medium"
    case hard   = "Hard"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .easy:   return "🌱"
        case .medium: return "⚡️"
        case .hard:   return "🔥"
        }
    }

    var description: String {
        switch self {
        case .easy:   return "Small amounts, hint available"
        case .medium: return "Hidden target, hints available"
        case .hard:   return "Large amounts, no hints"
        }
    }

    /// Round denominations used when calculating what the player "pays" with
    var paymentDenominations: [Int] {
        switch self {
        case .easy:   return [5, 10, 20, 50]
        case .medium: return [10, 20, 50]
        case .hard:   return [20, 50, 100]
        }
    }

    var showHintButton: Bool { self != .hard }
}

// MARK: - Coin Denomination

enum CoinDenomination: Int, CaseIterable, Identifiable, Sendable {
    case one        = 1
    case five       = 5
    case ten        = 10
    case twenty = 20

    var id: Int { rawValue }

    var label: String { "\(rawValue)" }

    var coinColor: Color {
        switch self {
        case .one:        return Color(red: 0.72, green: 0.45, blue: 0.20) // Bronze
        case .five:       return Color(red: 0.72, green: 0.72, blue: 0.72) // Silver
        case .ten:        return Color(red: 0.85, green: 0.65, blue: 0.13) // Gold
        case .twenty:     return Color(red: 0.94, green: 0.78, blue: 0.25) // Rich Gold
        }
    }

    var labelColor: Color {
        switch self {
        case .one:  return .white
        default:    return Color(red: 0.30, green: 0.20, blue: 0.10)
        }
    }

    /// Ascending display size for SplashView coin row
    /// Visual metaphor: bigger circle = more valuable  ← children read SIZE instantly
    var splashDisplaySize: CGFloat {
        switch self {
        case .one:    return 52
        case .five:   return 66
        case .ten:    return 80
        case .twenty: return 96
        }
    }

    /// Ascending display size for CoinIntroView value comparison
    var introDisplaySize: CGFloat {
        switch self {
        case .one:    return 44
        case .five:   return 58
        case .ten:    return 72
        case .twenty: return 88
        }
    }

    /// Short buying-power hint shown to children in the coin intro screen
    var buyingPowerHint: String {
        switch self {
        case .one:    return "Can't buy alone yet!"
        case .five:   return "Buys a Simit 🥯"
        case .ten:    return "Buys a Tost 🥪"
        case .twenty: return "Big spender! 🍫"
        }
    }

}

// MARK: - Purchase Record

struct Purchase: Identifiable, Sendable, Codable {
    let id = UUID()
    let product: Product
    let paidWith: Int    // coins paid by player
    let change: Int      // correct change amount

    // id is auto-generated for Identifiable only — exclude from Codable
    enum CodingKeys: String, CodingKey {
        case product, paidWith, change
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Sendable, Codable {
    let id: String
    let symbol: String   // SF Symbol name
    let title: String
    let subtitle: String
    var isUnlocked: Bool = false

    /// Each achievement gets a Pride color for inclusivity
    /// Not stored/encoded — computed from id
    var prideAccentColor: Color {
        switch id {
        case "first_purchase": return .prideRed
        case "change_master":  return .prideOrange
        case "smart_saver":    return .prideYellow
        case "budget_master":  return .prideBlue
        case "no_hint_hero":   return .prideGreen
        case "coin_mix":       return .pridePurple
        default:               return .simitSarisi
        }
    }

    static let all: [Achievement] = [
        Achievement(
            id: "first_purchase",
            symbol: "cart.badge.plus",
            title: "First Purchase!",
            subtitle: "You bought your first item at the canteen."
        ),
        Achievement(
            id: "change_master",
            symbol: "checkmark.seal.fill",
            title: "Change Master!",
            subtitle: "You calculated the correct change amount."
        ),
        Achievement(
            id: "smart_saver",
            symbol: "dollarsign.circle.fill",
            title: "Smart Saver!",
            subtitle: "You spent less than 20 coins — great saving!"
        ),
        Achievement(
            id: "budget_master",
            symbol: "banknote.fill",
            title: "Budget Master!",
            subtitle: "Saved 30 or more coins at the end."
        ),
        Achievement(
            id: "no_hint_hero",
            symbol: "lightbulb.slash.fill",
            title: "Independent Thinker!",
            subtitle: "You figured out the exact change all by yourself — no hints needed!"
        ),
        Achievement(
            id: "coin_mix",
            symbol: "circle.grid.3x3.fill",
            title: "Mix & Match!",
            subtitle: "You combined three or more different coin types to make exact change!"
        ),
    ]
}

// MARK: - Change Result

enum ChangeResult: Sendable, Equatable {
    case correct
    case tooMuch
}

// MARK: - Savings Goal

struct SavingsGoal: Identifiable, Sendable {
    let id: String
    let name: String
    let emoji: String
    let cost: Int        // in Canteen Coins

    /// Sessions to reach goal given coins saved per session
    func sessionsNeeded(coinsPerSession: Int) -> Int {
        guard coinsPerSession > 0 else { return 999 }
        return Int(ceil(Double(cost) / Double(coinsPerSession)))
    }

    static let all: [SavingsGoal] = [
        SavingsGoal(id: "toy_car",    name: "Toy Car",    emoji: "🚗", cost: 100),
        SavingsGoal(id: "book_set",   name: "Book Set",   emoji: "📚", cost: 60),
        SavingsGoal(id: "puzzle",     name: "Puzzle",     emoji: "🧩", cost: 80),
        SavingsGoal(id: "football",   name: "Football",   emoji: "⚽", cost: 120),
        SavingsGoal(id: "art_set",    name: "Art Set",    emoji: "🎨", cost: 90),
        SavingsGoal(id: "video_game", name: "Video Game", emoji: "🎮", cost: 150),
    ]
}
