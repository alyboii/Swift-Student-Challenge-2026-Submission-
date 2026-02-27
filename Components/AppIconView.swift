import SwiftUI

// MARK: - App Icon
// Cartoon character inspired by kids at my dad's school canteen.
// Built entirely in SwiftUI — no image assets.

// MARK: - Helper Shapes

/// Standard upward smile arc — flipped with scaleEffect(y:-1) for eyebrows, direct for smile
struct SmileArc: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(
            to:      CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return p
    }
}

/// Hoodie body — trapezoid: slightly narrower at top (shoulder slope), wider at bottom
struct HoodieBody: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset = rect.width * 0.08
        p.move(to:    CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX,         y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX,         y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// Lopsided grin — kept for module compatibility
struct LopsidedSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.20))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY - rect.height * 0.25),
            control1: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.maxY),
            control2: CGPoint(x: rect.minX + rect.width * 0.72, y: rect.minY + rect.height * 0.10)
        )
        return p
    }
}

/// Hat crown — kept for module compatibility
struct HatCrown: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.35))
        p.addQuadCurve(
            to:      CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.35),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - App Icon View

struct AppIconView: View {

    // Colors
    private let bgTop       = Color(red: 0.16, green: 0.72, blue: 0.38)  // bright green
    private let bgBot       = Color(red: 0.07, green: 0.42, blue: 0.20)  // deep green
    private let skin        = Color(red: 0.98, green: 0.85, blue: 0.72)  // warm skin
    private let skinDark    = Color(red: 0.86, green: 0.70, blue: 0.55)  // shadow / ear detail
    private let hairBrown   = Color(red: 0.40, green: 0.24, blue: 0.10)  // dark brown hair
    private let glassBlue   = Color(red: 0.15, green: 0.45, blue: 0.88)  // blue glasses
    private let hoodieGreen = Color(red: 0.22, green: 0.68, blue: 0.38)  // hoodie
    private let browColor   = Color(red: 0.28, green: 0.16, blue: 0.06)  // brows / mouth
    private let eyeIris     = Color(red: 0.35, green: 0.22, blue: 0.12)  // iris
    private let eyePupil    = Color(red: 0.10, green: 0.06, blue: 0.04)  // pupil
    private let cheekPink   = Color(red: 0.97, green: 0.71, blue: 0.71)  // rosy cheeks

    // Rainbow gradient for the coin
    private var rainbow: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.38, green: 0.78, blue: 1.00),  // sky blue
                Color(red: 0.62, green: 0.38, blue: 1.00),  // violet
                Color(red: 1.00, green: 0.48, blue: 0.78),  // pink
                Color(red: 1.00, green: 0.90, blue: 0.28),  // yellow
                Color(red: 0.38, green: 0.90, blue: 0.50),  // lime
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)

            ZStack {

                // Background — hierarchical green tones (HIG: use colour to signal category)
                LinearGradient(colors: [bgTop, bgBot], startPoint: .topLeading, endPoint: .bottomTrailing)

                // Hoodie — Canvas stripes clipped to trapezoid shape
                let green = hoodieGreen
                Canvas { ctx, size in
                    let h = size.height / 10.0
                    for i in 0..<10 {
                        let rect = CGRect(x: 0, y: CGFloat(i) * h, width: size.width, height: h)
                        ctx.fill(Path(rect), with: .color(i.isMultiple(of: 2) ? green : .white))
                    }
                }
                .frame(width: s * 0.92, height: s * 0.60)
                .clipShape(HoodieBody())
                .shadow(color: .black.opacity(0.18), radius: s * 0.012, x: 0, y: -s * 0.006)
                .offset(y: s * 0.265)

                // Hoodie drawstrings
                Capsule()
                    .fill(Color.white.opacity(0.70))
                    .frame(width: s * 0.014, height: s * 0.115)
                    .rotationEffect(.degrees(7))
                    .offset(x: -s * 0.058, y: s * 0.148)

                Capsule()
                    .fill(Color.white.opacity(0.70))
                    .frame(width: s * 0.014, height: s * 0.115)
                    .rotationEffect(.degrees(-7))
                    .offset(x: s * 0.058, y: s * 0.148)

                // Neck
                Capsule()
                    .fill(skin)
                    .frame(width: s * 0.112, height: s * 0.122)
                    .offset(y: s * 0.080)

                // Head
                Ellipse()
                    .fill(skin)
                    .shadow(color: skinDark.opacity(0.22), radius: s * 0.022, x: 0, y: s * 0.012)
                    .frame(width: s * 0.435, height: s * 0.415)
                    .offset(y: -s * 0.118)

                // Hair — messy brown, back mass + side curtains + spikes
                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.465, height: s * 0.250)
                    .offset(y: -s * 0.258)

                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.175, height: s * 0.225)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -s * 0.200, y: -s * 0.200)

                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.175, height: s * 0.225)
                    .rotationEffect(.degrees(18))
                    .offset(x: s * 0.200, y: -s * 0.200)

                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.115, height: s * 0.190)
                    .rotationEffect(.degrees(-26))
                    .offset(x: -s * 0.122, y: -s * 0.312)

                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.108, height: s * 0.180)
                    .rotationEffect(.degrees(4))
                    .offset(x: s * 0.022, y: -s * 0.320)

                Ellipse()
                    .fill(hairBrown)
                    .frame(width: s * 0.115, height: s * 0.185)
                    .rotationEffect(.degrees(24))
                    .offset(x: s * 0.158, y: -s * 0.302)

                // Ears
                Ellipse()
                    .fill(skin)
                    .overlay(Ellipse().stroke(skinDark.opacity(0.18), lineWidth: s * 0.006))
                    .frame(width: s * 0.065, height: s * 0.085)
                    .offset(x: -s * 0.220, y: -s * 0.118)

                Ellipse()
                    .fill(skin)
                    .overlay(Ellipse().stroke(skinDark.opacity(0.18), lineWidth: s * 0.006))
                    .frame(width: s * 0.065, height: s * 0.085)
                    .offset(x: s * 0.220, y: -s * 0.118)

                // Rosy cheeks
                Circle()
                    .fill(cheekPink.opacity(0.45))
                    .frame(width: s * 0.100)
                    .blur(radius: s * 0.014)
                    .offset(x: -s * 0.138, y: -s * 0.058)

                Circle()
                    .fill(cheekPink.opacity(0.45))
                    .frame(width: s * 0.100)
                    .blur(radius: s * 0.014)
                    .offset(x: s * 0.138, y: -s * 0.058)

                // Eyebrows
                SmileArc()
                    .stroke(browColor, style: StrokeStyle(lineWidth: s * 0.017, lineCap: .round))
                    .frame(width: s * 0.122, height: s * 0.032)
                    .scaleEffect(y: -1)
                    .offset(x: -s * 0.098, y: -s * 0.205)

                SmileArc()
                    .stroke(browColor, style: StrokeStyle(lineWidth: s * 0.017, lineCap: .round))
                    .frame(width: s * 0.122, height: s * 0.032)
                    .scaleEffect(y: -1)
                    .offset(x: s * 0.098, y: -s * 0.205)

                // Eyes — left
                ZStack {
                    Circle().fill(Color.white).frame(width: s * 0.106)
                    Circle().fill(eyeIris).frame(width: s * 0.072)
                    Circle().fill(eyePupil).frame(width: s * 0.038)
                        .offset(x: s * 0.006, y: s * 0.004)
                    Circle().fill(Color.white).frame(width: s * 0.017)
                        .offset(x: s * 0.020, y: -s * 0.018)
                }
                .offset(x: -s * 0.098, y: -s * 0.155)

                // Eyes — right
                ZStack {
                    Circle().fill(Color.white).frame(width: s * 0.106)
                    Circle().fill(eyeIris).frame(width: s * 0.072)
                    Circle().fill(eyePupil).frame(width: s * 0.038)
                        .offset(x: s * 0.006, y: s * 0.004)
                    Circle().fill(Color.white).frame(width: s * 0.017)
                        .offset(x: s * 0.020, y: -s * 0.018)
                }
                .offset(x: s * 0.098, y: -s * 0.155)

                // Nose
                Circle()
                    .fill(skinDark.opacity(0.38))
                    .frame(width: s * 0.026)
                    .offset(x: s * 0.010, y: -s * 0.095)

                // Smile
                SmileArc()
                    .stroke(browColor.opacity(0.78),
                            style: StrokeStyle(lineWidth: s * 0.021, lineCap: .round))
                    .frame(width: s * 0.180, height: s * 0.070)
                    .offset(y: -s * 0.045)

                // Glasses — eyeglasses SF Symbol in blue, positioned over the eyes
                Image(systemName: "eyeglasses")
                    .font(.system(size: s * 0.215))
                    .foregroundStyle(glassBlue)
                    .shadow(color: glassBlue.opacity(0.30), radius: s * 0.008)
                    .offset(y: -s * 0.148)

                // Left arm and sleeve
                Capsule()
                    .fill(hoodieGreen)
                    .frame(width: s * 0.138, height: s * 0.305)
                    .rotationEffect(.degrees(24))
                    .offset(x: -s * 0.285, y: s * 0.250)

                // Sleeve cuff
                Capsule()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: s * 0.130, height: s * 0.028)
                    .rotationEffect(.degrees(24))
                    .offset(x: -s * 0.278, y: s * 0.358)

                // Hand
                Ellipse()
                    .fill(skin)
                    .frame(width: s * 0.112, height: s * 0.092)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -s * 0.258, y: s * 0.365)

                // Rainbow coin — face.smiling.fill with .pulse over LinearGradient
                ZStack {
                    // Drop shadow
                    Circle()
                        .fill(Color.purple.opacity(0.25))
                        .frame(width: s * 0.218)
                        .blur(radius: s * 0.014)
                        .offset(x: s * 0.006, y: s * 0.012)

                    // Coin body — rainbow gradient
                    Circle()
                        .fill(rainbow)
                        .frame(width: s * 0.200)

                    // Coin rim
                    Circle()
                        .stroke(Color.white.opacity(0.65), lineWidth: s * 0.013)
                        .frame(width: s * 0.200)

                    // SF Symbols 7: face.smiling.fill + .symbolEffect(.pulse)
                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: s * 0.095))
                        .foregroundStyle(Color.white.opacity(0.92))
                        .symbolEffect(.pulse)

                    // Glare highlight
                    Ellipse()
                        .fill(Color.white.opacity(0.54))
                        .frame(width: s * 0.070, height: s * 0.042)
                        .offset(x: -s * 0.046, y: -s * 0.054)
                }
                .rotationEffect(.degrees(-12))
                .offset(x: -s * 0.238, y: s * 0.342)

                // Sparkle accent
                Image(systemName: "sparkle")
                    .font(.system(size: s * 0.072))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .offset(x: s * 0.360, y: s * 0.375)

            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Previews

#Preview("Icon 1024×1024") {
    AppIconView()
        .frame(width: 1024, height: 1024)
        .ignoresSafeArea()
}

#Preview("Phone 120pt") {
    AppIconView()
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
        .shadow(radius: 8)
        .padding()
}

#Preview("iPad 152pt") {
    AppIconView()
        .frame(width: 152, height: 152)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(radius: 10)
        .padding()
}

#Preview("Home Screen 60pt") {
    AppIconView()
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .shadow(radius: 4)
        .padding()
}
