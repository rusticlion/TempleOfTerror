import SwiftUI

struct CharacterSheetView: View {
    let character: Character
    var locationName: String? = nil

    @State private var selectedHarm: HarmInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Identity
            HStack(alignment: .firstTextBaseline) {
                Text(character.name)
                    .font(.headline)
                    .bold()
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
                    HStack(spacing: 2) {
                        ForEach(1...9, id: \.self) { index in
                            Image(character.stress >= index ? "icon_stress_pip_lit" : "icon_stress_pip_unlit")
                                .resizable()
                                .frame(width: 12, height: 12)
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
                                    selectedHarm = harmInfo(for: harm, level: .lesser)
                                } label: {
                                    Text(harm.description)
                                        .font(.caption2)
                                        .padding(4)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(4)
                                }
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
                                    selectedHarm = harmInfo(for: harm, level: .moderate)
                                } label: {
                                    Text(harm.description)
                                        .font(.caption2)
                                        .padding(4)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(4)
                                }
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
                            selectedHarm = harmInfo(for: harm, level: .severe)
                        } label: {
                            Text(harm.description)
                                .font(.caption2)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 4) {
                    ForEach(character.actions.sorted(by: { $0.key < $1.key }), id: \.key) { action, rating in
                        HStack(spacing: 4) {
                            Text(action)
                            HStack(spacing: 1) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image("icon_stress_pip_lit")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                }
                            }
                            Spacer()
                        }
                        .font(.caption2)
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
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
        .popover(item: $selectedHarm) { info in
            VStack(alignment: .leading, spacing: 4) {
                Text(info.title)
                    .font(.headline)
                Text(info.details)
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct HarmInfo: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

private func penaltyDescription(_ penalty: Penalty) -> String {
    switch penalty {
    case .reduceEffect:
        return "All actions suffer -1 Effect."
    case .increaseStressCost(let amount):
        return "+\(amount) Stress cost to push or resist."
    case .actionPenalty(let actionType):
        return "-1d to \(actionType)."
    case .banAction(let actionType):
        return "Cannot perform \(actionType)."
    }
}

private func harmInfo(for harm: (familyId: String, description: String), level: HarmLevel) -> HarmInfo {
    if let family = HarmLibrary.families[harm.familyId] {
        let tier: HarmTier
        switch level {
        case .lesser: tier = family.lesser
        case .moderate: tier = family.moderate
        case .severe: tier = family.severe
        }
        let penaltyText = tier.penalty.map { penaltyDescription($0) } ?? "No mechanical penalty."
        return HarmInfo(title: "\(level.rawValue.capitalized) Harm: \(tier.description)", details: penaltyText)
    }
    return HarmInfo(title: harm.description, details: "")
}

