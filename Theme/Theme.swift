import SwiftUI

// MARK: - 🎨 Canteen Colors

extension Color {
    // Primary Colors
    /// Simit Yellow — Primary: buttons, headings, focal points (vibrant in both modes)
    static let simitSarisi = Color(red: 0.96, green: 0.65, blue: 0.14)       // #F5A623
    /// Toast Orange — Secondary: accents, badges, icons (vibrant in both modes)
    static let tostTuruncusu = Color(red: 0.91, green: 0.45, blue: 0.16)     // #E8722A
    /// Ayran White — Warm background tone (adapts to dark mode)
    static let ayranBeyazi = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)  // Dark warm brown
                : UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)  // Light warm white
        }
    )
    /// Chocolate Brown — Text color (adapts to dark mode)
    static let cikolataKahvesi = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.90, blue: 0.85, alpha: 1)  // Light cream text
                : UIColor(red: 0.36, green: 0.24, blue: 0.18, alpha: 1)  // Dark brown text
        }
    )

    // Utility Colors
    /// Success states, correct answer
    static let basariYesili = Color(red: 0.30, green: 0.69, blue: 0.31)      // #4CAF50
    /// Error states, wrong answer
    static let hataKirmizisi = Color(red: 0.90, green: 0.22, blue: 0.21)     // #E53935

    // MARK: - Apple Pride Colors
    // Apple celebrates Pride annually with products, Watch bands, and wallpapers.
    // Each achievement has a distinct colour from the Pride palette.
    static let prideRed    = Color(red: 1.00, green: 0.23, blue: 0.19)  // #FF3B30
    static let prideOrange = Color(red: 1.00, green: 0.58, blue: 0.00)  // #FF9500
    static let prideYellow = Color(red: 1.00, green: 0.80, blue: 0.00)  // #FFCC00
    static let prideGreen  = Color(red: 0.20, green: 0.78, blue: 0.35)  // #34C759
    static let prideBlue   = Color(red: 0.00, green: 0.48, blue: 1.00)  // #007AFF
    static let pridePurple = Color(red: 0.69, green: 0.32, blue: 0.87)  // #AF52DE

    /// All Pride colors as an array — use for gradients and confetti
    static let prideColors: [Color] = [prideRed, prideOrange, prideYellow, prideGreen, prideBlue, pridePurple]

    /// Pride gradient — for progress rings, bars, and celebration moments
    static let prideGradient = LinearGradient(
        colors: prideColors,
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - 🔤 Canteen Typography (SF Rounded)

struct CanteenTypography {
    /// Large Title Bold Rounded — Main screen headings (Dynamic Type supported)
    static let heroTitle: Font = .system(.largeTitle, design: .rounded).weight(.bold)
    /// Title2 Semibold Rounded — Section headings (Dynamic Type supported)
    static let sectionTitle: Font = .system(.title2, design: .rounded).weight(.semibold)
    /// Body Regular Rounded — General content text (Dynamic Type supported)
    static let bodyText: Font = .system(.body, design: .rounded)
    /// Footnote Medium Rounded — Helper text, labels (Dynamic Type supported)
    static let caption: Font = .system(.footnote, design: .rounded).weight(.medium)
    /// Headline Bold Rounded — Button labels (Dynamic Type supported)
    static let buttonLabel: Font = .system(.headline, design: .rounded).weight(.bold)
}

// MARK: - 📐 Canteen Spacing & Radius

struct CanteenSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

struct CanteenRadius {
    static let s: CGFloat = 8
    static let m: CGFloat = 14
    static let l: CGFloat = 20
    static let full: CGFloat = 999
}

// MARK: - 🔘 Primary Button Style (Simit Button)

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CanteenTypography.buttonLabel)
            .foregroundStyle(Color.cikolataKahvesi)
            .padding(.vertical, CanteenSpacing.m)
            .padding(.horizontal, CanteenSpacing.xl)
            .background(Color.simitSarisi)
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m + 2))
            .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 🔘 Secondary Button Style (Toast Button)

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.tostTuruncusu)
            .padding(.vertical, 12)
            .padding(.horizontal, CanteenSpacing.l)
            .background(Color.tostTuruncusu.opacity(configuration.isPressed ? 0.25 : 0.15))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: CanteenRadius.m)
                    .stroke(Color.tostTuruncusu, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 🔘 Ghost Button Style (Ayran Button)

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Color.simitSarisi)
            .padding(.vertical, 10)
            .padding(.horizontal, CanteenSpacing.l)
            .background(configuration.isPressed ? Color.ayranBeyazi : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 🧩 Convenience View Extensions

extension View {
    /// Applies warm canteen background to a page
    func canteenBackground() -> some View {
        self.background(Color.ayranBeyazi.ignoresSafeArea())
    }

    /// Applies canteen card style (non Liquid Glass fallback)
    func canteenCard() -> some View {
        self
            .padding(CanteenSpacing.m)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.l))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    /// iOS 26 Liquid Glass card style — for floating/overlay elements
    /// Falls back to opaque white if reduceTransparency is enabled
    func glassCard(cornerRadius: CGFloat = CanteenRadius.l) -> some View {
        self
            .padding(CanteenSpacing.m)
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
    }

    /// iOS 26 Liquid Glass container — for grouping multiple glass elements
    func glassContainer(cornerRadius: CGFloat = CanteenRadius.l) -> some View {
        self
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - 🪟 Liquid Glass Button Style (iOS 26)

struct GlassButtonStyle: ButtonStyle {
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CanteenTypography.buttonLabel)
            .foregroundStyle(prominent ? Color.cikolataKahvesi : Color.simitSarisi)
            .padding(.vertical, CanteenSpacing.m)
            .padding(.horizontal, CanteenSpacing.xl)
            .glassEffect(in: .rect(cornerRadius: CanteenRadius.m + 2))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var canteenGlass: GlassButtonStyle { GlassButtonStyle() }
    static var canteenGlassProminent: GlassButtonStyle { GlassButtonStyle(prominent: true) }
}

// MARK: - 🏷️ Button Style Shortcuts

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var canteenPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var canteenSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var canteenGhost: GhostButtonStyle { GhostButtonStyle() }
}

// MARK: - Canteen Coin Icon
// Single source of truth for the coin icon used throughout the app.
// To swap in a custom drawing: add a PNG/PDF named "canteenCoin" to Assets.xcassets,
// then replace Image(systemName:) with Image("canteenCoin") in coinView(size:).

struct CanteenCoinIcon: View {
    var size: CGFloat = 12

    var body: some View {
        // ↓ Swap this for Image("canteenCoin") once asset is added to Assets.xcassets
        Image(systemName: "circle.fill")
            .font(.system(size: size))
    }
}

// MARK: - Coin Amount Label
// Renders a number + the canteen coin icon inline.
// Use everywhere a coin amount appears — replaces raw 🪙 emoji.

struct CoinAmountLabel: View {
    let amount: Int
    var font: Font = CanteenTypography.caption
    var amountColor: Color = Color.cikolataKahvesi
    var coinColor: Color = Color.simitSarisi

    var body: some View {
        HStack(spacing: 2) {
            Text("\(amount)")
                .font(font)
                .foregroundStyle(amountColor)
            Image(systemName: "circle.fill")
                .font(font)
                .foregroundStyle(coinColor)
        }
    }
}

// MARK: - 🌈 MeshGradient Preset (iOS 18+)

struct CanteenMeshGradient: View {
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    @State private var t: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let x1 = Float((sin(elapsed * 0.4) + 1) / 2)
            let x2 = Float((cos(elapsed * 0.3) + 1) / 2)
            let y1 = Float((sin(elapsed * 0.25 + 1) + 1) / 2)

            let isDark = colorScheme == .dark

            MeshGradient(width: 3, height: 3, points: [
                [0, 0],     [0.5, 0],    [1, 0],
                [0, 0.5],   [x1, y1],    [1, 0.5],
                [0, 1],     [x2, 1],     [1, 1]
            ], colors: isDark ? [
                // Dark mode — deep warm tones
                Color.simitSarisi.opacity(0.12),
                Color.tostTuruncusu.opacity(0.08),
                Color.simitSarisi.opacity(0.10),
                Color.ayranBeyazi,
                Color.simitSarisi.opacity(0.14),
                Color.ayranBeyazi,
                Color.ayranBeyazi,
                Color.tostTuruncusu.opacity(0.06),
                Color.ayranBeyazi
            ] : [
                // Light mode — warm canteen glow
                Color.simitSarisi.opacity(0.35),
                Color.tostTuruncusu.opacity(0.20),
                Color.simitSarisi.opacity(0.25),
                Color.ayranBeyazi,
                Color.simitSarisi.opacity(0.30),
                Color.ayranBeyazi,
                Color.ayranBeyazi,
                Color.tostTuruncusu.opacity(0.15),
                Color.ayranBeyazi
            ])
            .ignoresSafeArea()
        }
    }
}
