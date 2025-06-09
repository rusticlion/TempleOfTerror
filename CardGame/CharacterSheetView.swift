import SwiftUI

struct CharacterSheetView: View {
    struct SelectedHarm: Identifiable {
        let familyId: String
        let level: HarmLevel
        var id: String { familyId + level.rawValue }
    }

    let character: Character
    var locationName: String? = nil
    @State private var selectedTreasure: Treasure? = nil
    @State private var selectedHarm: SelectedHarm? = nil

    private func tier(for familyId: String, level: HarmLevel) -> HarmTier? {
        guard let family = HarmLibrary.families[familyId] else { return nil }
        switch level {
        case .lesser: return family.lesser
        case .moderate: return family.moderate
        case .severe: return family.severe
        }
    }

    private func shortPenaltyDescription(_ penalty: Penalty) -> String {
        switch penalty {
        case .reduceEffect: return "-1 Effect"
        case .increaseStressCost(let amount): return "+\(amount) Stress cost"
        case .actionPenalty(let actionType): return "\(actionType) -1d"
        case .banAction(let actionType): return "No \(actionType)"
        }
    }

    private func shortBoonDescription(_ boon: Modifier) -> String {
        var parts: [String] = []
        if boon.bonusDice != 0 { parts.append("+\(boon.bonusDice)d") }
        if boon.improvePosition { parts.append("Pos+") }
        if boon.improveEffect { parts.append("Effect+") }
        if parts.isEmpty { return boon.description }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Identity
            HStack(alignment: .firstTextBaseline) {
                Text(character.name)
                    .font(.headline)
                    .bold()
                if character.isDefeated {
                    Text("DEFEATED")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                Spacer()
                Text(character.characterClass)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let locationName {
                Text("At: \(locationName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Vital stats block
            VStack(alignment: .center, spacing: 6) {
                // Stress
                VStack(alignment: .center, spacing: 2) {
                    Text("Stress \(character.stress)/9")
                        .font(.caption2)
                    HStack(spacing: 4) {
                        ForEach(1...9, id: \.self) { index in
                            Image(character.stress >= index ? "icon_stress_pip_lit" : "icon_stress_pip_unlit")
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }
                }

                // Harm
                VStack(alignment: .center, spacing: 4) {
                    Text("Harm")
                        .font(.caption2)

                    // Lesser Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.lesserSlots, id: \.self) { index in
                            if index < character.harm.lesser.count {
                                let harm = character.harm.lesser[index]
                                Button {
                                    selectedHarm = SelectedHarm(familyId: harm.familyId, level: .lesser)
                                } label: {
                                    VStack {
                                        Text(harm.description)
                                            .fixedSize(horizontal: false, vertical: true)
                                        if let tier = tier(for: harm.familyId, level: .lesser) {
                                            if let penalty = tier.penalty {
                                                Text(shortPenaltyDescription(penalty))
                                                    .foregroundColor(.red)
                                            }
                                            if let boon = tier.boon {
                                                Text(shortBoonDescription(boon))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("None")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Moderate Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                            if index < character.harm.moderate.count {
                                let harm = character.harm.moderate[index]
                                Button {
                                    selectedHarm = SelectedHarm(familyId: harm.familyId, level: .moderate)
                                } label: {
                                    VStack {
                                        Text(harm.description)
                                            .fixedSize(horizontal: false, vertical: true)
                                        if let tier = tier(for: harm.familyId, level: .moderate) {
                                            if let penalty = tier.penalty {
                                                Text(shortPenaltyDescription(penalty))
                                                    .foregroundColor(.red)
                                            }
                                            if let boon = tier.boon {
                                                Text(shortBoonDescription(boon))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("None")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Severe Harm
                    if let harm = character.harm.severe.first {
                        Button {
                            selectedHarm = SelectedHarm(familyId: harm.familyId, level: .severe)
                        } label: {
                            VStack {
                                Text(harm.description)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let tier = tier(for: harm.familyId, level: .severe) {
                                    if let penalty = tier.penalty {
                                        Text(shortPenaltyDescription(penalty))
                                            .foregroundColor(.red)
                                    }
                                    if let boon = tier.boon {
                                        Text(shortBoonDescription(boon))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .padding(4)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("None")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(4)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 8)
            }
            .padding(6)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(8)

            // Actions
            VStack(alignment: .leading, spacing: 4) {
                Text("Actions")
                    .font(.caption2)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(character.actions.sorted(by: { $0.key < $1.key }), id: \.key) { action, rating in
                        HStack(spacing: 4) {
                            Text(action)
                                .font(.caption)
                            HStack(spacing: 1) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image("icon_stress_pip_lit")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }

            // Treasures
            if !character.treasures.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Treasures")
                        .font(.caption2)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(character.treasures) { treasure in
                                Button {
                                    selectedTreasure = treasure
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(treasure.name)
                                        if !treasure.tags.isEmpty {
                                            HStack(spacing: 2) {
                                                ForEach(treasure.tags, id: \.self) { tag in
                                                    Text(tag)
                                                        .font(.caption2)
                                                        .padding(2)
                                                        .background(Color(UIColor.systemGray5))
                                                        .cornerRadius(4)
                                                }
                                            }
                                        }
                                    }
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color(UIColor.systemBackground).opacity(0.5))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
        .popover(item: $selectedTreasure) { treasure in
            TreasureTooltipView(treasure: treasure)
        }
        .popover(item: $selectedHarm) { harm in
            HarmTooltipView(familyId: harm.familyId, level: harm.level)
        }
    }
}
