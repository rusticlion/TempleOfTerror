import SwiftUI

struct CharacterSheetView: View {
    struct SelectedHarm: Identifiable {
        let familyId: String
        let level: HarmLevel
        var id: String { familyId + level.rawValue }
    }

    let character: Character
    var locationName: String? = nil
    let harmFamilies: [String: HarmFamily]
    @State private var selectedTreasure: Treasure? = nil
    @State private var selectedHarm: SelectedHarm? = nil

    private func tier(for familyId: String, level: HarmLevel) -> HarmTier? {
        guard let family = harmFamilies[familyId] else { return nil }
        switch level {
        case .lesser: return family.lesser
        case .moderate: return family.moderate
        case .severe: return family.severe
        }
    }

    private func shortPenaltyDescription(_ penalty: Penalty) -> String {
        penalty.shortDescription
    }

    private func shortBoonDescription(_ boon: Modifier) -> String {
        boon.shortDescription
    }

    private func tint(for level: HarmLevel) -> (fill: Color, border: Color) {
        switch level {
        case .lesser:
            return (Theme.goldDim.opacity(0.1), Theme.goldDim.opacity(0.3))
        case .moderate:
            return (Theme.danger.opacity(0.1), Theme.danger.opacity(0.3))
        case .severe:
            return (Theme.danger.opacity(0.15), Theme.danger.opacity(0.4))
        }
    }

    @ViewBuilder
    private func harmRow(level: HarmLevel,
                         entries: [(familyId: String, description: String)],
                         slots: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<slots, id: \.self) { index in
                if index < entries.count {
                    let harm = entries[index]
                    let tierData = tier(for: harm.familyId, level: level)
                    let style = tint(for: level)
                    Button {
                        selectedHarm = SelectedHarm(familyId: harm.familyId, level: level)
                    } label: {
                        VStack(spacing: 2) {
                            Text(harm.description)
                                .font(Theme.bodyFont(size: 11))
                                .foregroundColor(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            if let penalty = tierData?.penalty {
                                Text(shortPenaltyDescription(penalty))
                                    .font(Theme.systemFont(size: 9, weight: .semibold))
                                    .foregroundColor(Theme.danger)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            if let boon = tierData?.boon {
                                Text(shortBoonDescription(boon))
                                    .font(Theme.systemFont(size: 9, weight: .semibold))
                                    .foregroundColor(Theme.success)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .background(style.fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(style.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                } else {
                    let emptyStyle = tint(for: level)
                    Text("—")
                        .font(Theme.bodyFont(size: 13))
                        .foregroundColor(Theme.inkFaded)
                        .padding(5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                .foregroundColor(emptyStyle.border.opacity(0.7))
                        )
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(character.name)
                    .font(Theme.displayFont(size: 18))
                    .foregroundColor(Theme.ink)
                if character.isDefeated {
                    Text("DEFEATED")
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .foregroundColor(Theme.danger)
                        .padding(.leading, 4)
                }
                Spacer()
                Text(character.characterClass)
                    .font(Theme.systemFont(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(Theme.inkFaded)
            }

            if let locationName {
                Text("At: \(locationName)")
                    .font(Theme.systemFont(size: 11))
                    .foregroundColor(Theme.inkFaded)
            }

            VStack(alignment: .leading, spacing: 7) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Stress \(character.stress)/9")
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(Theme.inkLight)
                    HStack(spacing: 3) {
                        ForEach(1...9, id: \.self) { index in
                            Circle()
                                .fill(
                                    character.stress >= index
                                    ? Theme.gold
                                    : Theme.ink.opacity(0.3)
                                )
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            character.stress >= index
                                            ? Theme.goldBright
                                            : Theme.inkFaded.opacity(0.3),
                                            lineWidth: 0.5
                                        )
                                )
                                .shadow(
                                    color: character.stress >= index ? Theme.gold.opacity(0.4) : .clear,
                                    radius: 3
                                )
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Harm")
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(Theme.inkLight)
                    harmRow(level: .lesser,
                            entries: character.harm.lesser,
                            slots: HarmState.lesserSlots)
                    harmRow(level: .moderate,
                            entries: character.harm.moderate,
                            slots: HarmState.moderateSlots)
                    harmRow(level: .severe,
                            entries: character.harm.severe,
                            slots: HarmState.severeSlots)
                }
            }
            .padding(6)
            .background(Theme.parchment.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.parchmentDeep.opacity(0.3), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Actions")
                    .font(Theme.systemFont(size: 11, weight: .medium))
                    .foregroundColor(Theme.inkLight)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(character.actions.sorted(by: { $0.key < $1.key }), id: \.key) { actionName, rating in
                        HStack(spacing: 4) {
                            Text(actionName)
                                .font(Theme.bodyFont(size: 11))
                                .foregroundColor(Theme.inkLight)
                            Text(String(repeating: "●", count: rating) + String(repeating: "○", count: max(0, 4 - rating)))
                                .font(Theme.systemFont(size: 11))
                                .foregroundColor(Theme.gold)
                                .tracking(1)
                            Spacer()
                        }
                    }
                }
            }

            if !character.treasures.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Treasures")
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(Theme.inkLight)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(character.treasures) { treasure in
                                Button {
                                    selectedTreasure = treasure
                                } label: {
                                    TreasureSummaryCard(treasure: treasure)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.parchmentDeep.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
        .popover(item: $selectedTreasure) { treasure in
            TreasureTooltipView(treasure: treasure)
        }
        .popover(item: $selectedHarm) { harm in
            HarmTooltipView(familyId: harm.familyId, level: harm.level, harmFamilies: harmFamilies)
        }
    }
}

private struct TreasureSummaryCard: View {
    let treasure: Treasure

    private var useLabel: String {
        if treasure.grantedModifier.uses > 0 {
            let uses = treasure.grantedModifier.uses
            return "\(uses) use" + (uses == 1 ? "" : "s")
        }
        return "Reusable"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("Treasure")
                    .font(Theme.systemFont(size: 10, weight: .semibold))
                    .foregroundColor(Theme.goldDim)
                    .textCase(.uppercase)
                    .tracking(0.7)

                Spacer(minLength: 8)

                Text(useLabel)
                    .font(Theme.systemFont(size: 9, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Theme.gold.opacity(0.2), in: Capsule())
            }

            Text(treasure.name)
                .font(Theme.displayFont(size: 16, weight: .semibold))
                .foregroundColor(Theme.ink)
                .lineLimit(2)

            Text(treasure.description)
                .font(Theme.bodyFont(size: 12, italic: true))
                .foregroundColor(Theme.inkLight)
                .lineLimit(3)

            Theme.InkDivider()

            Text(treasure.grantedModifier.longDescription)
                .font(Theme.systemFont(size: 10, weight: .medium))
                .foregroundColor(Theme.inkFaded)
                .lineLimit(3)

            if !treasure.tags.isEmpty {
                Text(treasure.tags.joined(separator: "  •  "))
                    .font(Theme.systemFont(size: 9, weight: .semibold))
                    .foregroundColor(Theme.goldDim)
                    .lineLimit(1)
            }
        }
        .frame(width: 170, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(
                colors: [Theme.parchment, Theme.gold.opacity(0.14), Theme.parchmentDark.opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.goldDim.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Theme.gold.opacity(0.18), radius: 6, y: 3)
    }
}
