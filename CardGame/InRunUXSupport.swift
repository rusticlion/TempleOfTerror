import SwiftUI

enum InRunHintID: String, CaseIterable, Hashable {
    case activeClocks
    case threatLock
    case rollForecast
    case resistancePrompt
    case splitParty
}

final class GuidanceStore: ObservableObject {
    static let storageKey = "inRunGuidance.seenHints"

    @Published private(set) var seenHints: Set<InRunHintID>

    private let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = .standard,
        resetOnLaunch: Bool = ProcessInfo.processInfo.environment["CODEX_RESET_GUIDANCE_HINTS"] == "1"
    ) {
        self.userDefaults = userDefaults

        if resetOnLaunch {
            userDefaults.removeObject(forKey: Self.storageKey)
        }

        let storedValues = userDefaults.stringArray(forKey: Self.storageKey) ?? []
        self.seenHints = Set(storedValues.compactMap(InRunHintID.init(rawValue:)))
    }

    func shouldShow(_ hintID: InRunHintID) -> Bool {
        !seenHints.contains(hintID)
    }

    func dismiss(_ hintID: InRunHintID) {
        guard seenHints.insert(hintID).inserted else { return }
        persist()
    }

    func debugResetHints() {
        seenHints.removeAll()
        userDefaults.removeObject(forKey: Self.storageKey)
    }

    private func persist() {
        userDefaults.set(seenHints.map(\.rawValue).sorted(), forKey: Self.storageKey)
    }
}

struct InlineExplainerAffordance: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle")
                Text(label)
            }
            .font(Theme.systemFont(size: 11, weight: .semibold))
            .foregroundColor(Theme.gold)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

struct GuidanceHintCard: View {
    let hintID: InRunHintID
    let title: String
    let message: String
    let onDismiss: () -> Void
    var onOpenReference: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.systemFont(size: 12, weight: .semibold))
                        .foregroundColor(Theme.parchment)
                        .textCase(.uppercase)
                        .tracking(0.6)

                    Text(message)
                        .font(Theme.bodyFont(size: 13))
                        .foregroundColor(Theme.parchmentDark)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Button("Got it", action: onDismiss)
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.gold, in: Capsule())
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidanceHintDismiss_\(hintID.rawValue)")
            }

            if let onOpenReference {
                InlineExplainerAffordance(label: "Open quick reference", action: onOpenReference)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.leatherLight.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.goldDim.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("guidanceHint_\(hintID.rawValue)")
    }
}

struct DualLabelForecastChip: View {
    let title: String
    let value: String
    let accent: Color
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 1 : 2) {
            Text(title)
                .font(Theme.systemFont(size: compact ? 9 : 10, weight: .semibold))
                .foregroundColor(Theme.inkFaded)
                .textCase(.uppercase)
                .tracking(0.6)
            Text(value)
                .font(compact ? Theme.systemFont(size: 11, weight: .semibold) : Theme.displayFont(size: 16, weight: .semibold))
                .foregroundColor(accent)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 6 : 8)
        .background(accent.opacity(compact ? 0.12 : 0.14), in: RoundedRectangle(cornerRadius: compact ? 8 : 10))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 8 : 10)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

struct InRunStateBadge: View {
    let text: String
    let foreground: Color
    let fill: Color

    var body: some View {
        Text(text)
            .font(Theme.systemFont(size: 10, weight: .semibold))
            .foregroundColor(foreground)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(fill, in: Capsule())
    }
}

struct SelectedCharacterSummaryStrip: View {
    let character: Character
    var locationName: String?
    var showLocation: Bool = false

    private var harmStateLabel: String {
        if character.isDefeated {
            return "Defeated"
        }
        if !character.harm.severe.isEmpty {
            return "Severe harm"
        }
        if !character.harm.moderate.isEmpty {
            return "Moderate harm"
        }
        if !character.harm.lesser.isEmpty {
            return "Lesser harm"
        }
        return "Fresh"
    }

    private var harmTint: Color {
        if character.isDefeated || !character.harm.severe.isEmpty {
            return Theme.danger
        }
        if !character.harm.moderate.isEmpty {
            return Theme.dangerLight
        }
        if !character.harm.lesser.isEmpty {
            return Theme.gold
        }
        return Theme.success
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(Theme.displayFont(size: 20, weight: .semibold))
                    .foregroundColor(Theme.parchment)

                Text(character.characterClass)
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .foregroundColor(Theme.inkFaded)
                    .textCase(.uppercase)
                    .tracking(0.7)

                if showLocation, let locationName {
                    Text(locationName)
                        .font(Theme.bodyFont(size: 13, italic: true))
                        .foregroundColor(Theme.parchmentDark)
                        .accessibilityIdentifier("selectedCharacterSummaryLocation")
                }
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 8) {
                InRunStateBadge(
                    text: "Stress \(character.stress)/9",
                    foreground: Theme.ink,
                    fill: Theme.gold.opacity(0.82)
                )

                InRunStateBadge(
                    text: harmStateLabel,
                    foreground: harmTint == Theme.gold ? Theme.ink : .white,
                    fill: harmTint.opacity(0.8)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.leatherLight.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.parchmentDeep.opacity(0.24), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("selectedCharacterSummaryStrip")
    }
}

struct CondensedClockRow: View {
    let clock: GameClock

    private var clampedProgress: Int {
        min(max(clock.progress, 0), clock.segments)
    }

    private var urgencyColor: Color {
        if clock.segments == 0 {
            return Theme.inkFaded
        }
        if clampedProgress >= clock.segments {
            return Theme.danger
        }
        if clampedProgress >= max(clock.segments - 1, 1) {
            return Theme.dangerLight
        }
        if clampedProgress * 2 >= clock.segments {
            return Theme.gold
        }
        return Theme.success
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(urgencyColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(clock.name)
                        .font(Theme.bodyFont(size: 14))
                        .foregroundColor(Theme.parchment)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text("\(clock.progress)/\(clock.segments)")
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.parchmentDark)
                }

                HStack(spacing: 4) {
                    ForEach(0..<clock.segments, id: \.self) { index in
                        Capsule()
                            .fill(index < clampedProgress ? urgencyColor : Theme.inkFaded.opacity(0.18))
                            .frame(maxWidth: .infinity)
                            .frame(height: 6)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.bg.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(urgencyColor.opacity(0.25), lineWidth: 1)
        )
    }
}

struct CondensedClockPanel: View {
    let clocks: [GameClock]
    let onOpenReference: () -> Void

    private var visibleClocks: [GameClock] {
        clocks.filter { $0.progress > 0 }
    }

    var body: some View {
        if !visibleClocks.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "hourglass.bottomhalf.filled")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.gold)

                    Text("Active Clocks")
                        .font(Theme.displayFont(size: 18, weight: .semibold))
                        .foregroundColor(Theme.parchment)

                    Spacer()

                    InlineExplainerAffordance(label: "What are clocks?", action: onOpenReference)
                }

                VStack(spacing: 8) {
                    ForEach(visibleClocks) { clock in
                        CondensedClockRow(clock: clock)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.leather.opacity(0.88))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.goldDim.opacity(0.22), lineWidth: 1)
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("condensedClockPanel")
        }
    }
}

enum InRunBannerStyle: String {
    case threat
    case split
    case neutral
}

struct ContextualInfoBanner: View {
    let style: InRunBannerStyle
    let title: String
    let message: String

    private var tint: Color {
        switch style {
        case .threat:
            return Theme.danger
        case .split:
            return Theme.gold
        case .neutral:
            return Theme.success
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(Theme.systemFont(size: 12, weight: .semibold))
                    .foregroundColor(Theme.parchment)
                    .textCase(.uppercase)
                    .tracking(0.7)

                Text(message)
                    .font(Theme.bodyFont(size: 13))
                    .foregroundColor(Theme.parchmentDark)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tint.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("contextualBanner_\(style.rawValue)")
    }

    private var iconName: String {
        switch style {
        case .threat:
            return "exclamationmark.triangle.fill"
        case .split:
            return "arrow.triangle.branch"
        case .neutral:
            return "figure.walk.motion"
        }
    }
}

struct QuickReferenceSheetView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(title: String, rows: [(String, String)])] = [
        (
            "Risk and Impact",
            [
                ("Risk", "Shows how dangerous the action is if things go badly."),
                ("Controlled", "Safer. Consequences are lighter or easier to manage."),
                ("Risky", "The default. Things can go wrong in meaningful ways."),
                ("Desperate", "Severe danger. Failure or partial success can hurt."),
                ("Impact", "Shows how much a success is expected to accomplish."),
                ("Limited / Standard / Great", "Success lands weakly, normally, or strongly.")
            ]
        ),
        (
            "Resources",
            [
                ("Stress", "You spend or take Stress to push harder and resist trouble."),
                ("Push", "Spend Stress before a roll to improve your odds."),
                ("Resist", "After a consequence appears, roll to reduce or avoid it by paying Stress."),
                ("Harm", "Lasting injuries or afflictions that can weaken or block actions.")
            ]
        ),
        (
            "Scenario Pressure",
            [
                ("Clocks", "Track growing danger, progress, or unstable situations."),
                ("Threats", "Dangerous obstacles that block normal movement until handled."),
                ("Split Movement", "In solo movement, only the selected explorer moves; splitting the party can help or expose you.")
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .font(Theme.displayFont(size: 22, weight: .semibold))
                                .foregroundColor(Theme.parchment)

                            ForEach(Array(section.rows.enumerated()), id: \.offset) { _, row in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(row.0)
                                        .font(Theme.systemFont(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.gold)
                                        .textCase(.uppercase)
                                        .tracking(0.6)

                                    Text(row.1)
                                        .font(Theme.bodyFont(size: 15))
                                        .foregroundColor(Theme.parchmentDark)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.leatherLight.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.bgWarm)
            .presentationBackground(Theme.bgWarm)
            .navigationTitle("Quick Reference")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.parchment)
                }
            }
        }
        .accessibilityIdentifier("quickReferenceSheet")
    }
}
