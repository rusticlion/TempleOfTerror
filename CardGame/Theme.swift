import SwiftUI

struct Theme {

    // MARK: - Colors

    static let bg             = Color(red: 0.071, green: 0.063, blue: 0.055)       // #12100e
    static let bgWarm         = Color(red: 0.102, green: 0.090, blue: 0.078)       // #1a1714
    static let parchment      = Color(red: 0.886, green: 0.835, blue: 0.745)       // #e2d5be
    static let parchmentDark  = Color(red: 0.788, green: 0.722, blue: 0.592)       // #c9b897
    static let parchmentDeep  = Color(red: 0.710, green: 0.627, blue: 0.478)       // #b5a07a
    static let ink            = Color(red: 0.173, green: 0.141, blue: 0.094)       // #2c2418
    static let inkLight       = Color(red: 0.353, green: 0.302, blue: 0.227)       // #5a4d3a
    static let inkFaded       = Color(red: 0.541, green: 0.490, blue: 0.416)       // #8a7d6a
    static let gold           = Color(red: 0.769, green: 0.643, blue: 0.306)       // #c4a44e
    static let goldDim        = Color(red: 0.604, green: 0.502, blue: 0.239)       // #9a803d
    static let goldBright     = Color(red: 0.878, green: 0.769, blue: 0.384)       // #e0c462
    static let danger         = Color(red: 0.639, green: 0.188, blue: 0.157)       // #a33028
    static let dangerLight    = Color(red: 0.769, green: 0.290, blue: 0.247)       // #c44a3f
    static let success        = Color(red: 0.290, green: 0.478, blue: 0.227)       // #4a7a3a
    static let leather        = Color(red: 0.180, green: 0.149, blue: 0.125)       // #2e2620
    static let leatherLight   = Color(red: 0.239, green: 0.200, blue: 0.165)       // #3d332a

    // MARK: - Position Colors

    static func positionColor(_ position: RollPosition) -> Color {
        switch position {
        case .controlled: return success
        case .risky:      return gold
        case .desperate:  return danger
        }
    }

    // MARK: - Fonts

    // Display — Cormorant Garamond
    static func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        switch weight {
        case .semibold:
            return .custom("CormorantGaramond-SemiBold", size: size)
        default:
            return .custom("CormorantGaramond-Bold", size: size)
        }
    }

    // Body — EB Garamond
    static func bodyFont(size: CGFloat, italic: Bool = false) -> Font {
        if italic {
            return .custom("EBGaramond-Italic", size: size)
        }
        return .custom("EBGaramond-Regular", size: size)
    }

    static func bodyFontMedium(size: CGFloat) -> Font {
        .custom("EBGaramondRoman-Medium", size: size)
    }

    // System/Mechanical — Source Sans 3
    static func systemFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .light:
            return .custom("SourceSans3-Roman_Light", size: size)
        case .medium:
            return .custom("SourceSans3-Roman_Medium", size: size)
        case .semibold, .bold:
            return .custom("SourceSans3-Roman_SemiBold", size: size)
        default:
            return .custom("SourceSans3-Roman_Regular", size: size)
        }
    }

    // MARK: - Reusable Modifiers

    /// Parchment card background with subtle gradient.
    static let cardBackground = LinearGradient(
        colors: [parchment, parchmentDark.opacity(0.87)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The dark radial background used behind dice rolls.
    static let dramaticBackground = RadialGradient(
        colors: [bgWarm, bg],
        center: .init(x: 0.5, y: 0.4),
        startRadius: 0,
        endRadius: 400
    )

    /// The leather-toned toolbar gradient at the bottom of the screen.
    static let toolbarBackground = LinearGradient(
        colors: [leather, bg],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Horizontal divider styled as a faded ink line.
    struct InkDivider: View {
        var body: some View {
            LinearGradient(
                colors: [.clear, Theme.parchmentDeep.opacity(0.5), Theme.parchmentDeep.opacity(0.5), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
    }
}
