import SwiftUI

struct CharacterSheetView: View {
    let character: Character
    var locationName: String? = nil

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
                            Text(index < character.harm.lesser.count ? character.harm.lesser[index].description : "None")
                                .font(.caption2)
                                .foregroundColor(index < character.harm.lesser.count ? .primary : .gray)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
                    }

                    // Moderate Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                            Text(index < character.harm.moderate.count ? character.harm.moderate[index].description : "None")
                                .font(.caption2)
                                .foregroundColor(index < character.harm.moderate.count ? .primary : .gray)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
                    }

                    // Severe Harm
                    Text(character.harm.severe.first?.description ?? "None")
                        .font(.caption2)
                        .foregroundColor(character.harm.severe.isEmpty ? .gray : .primary)
                        .padding(4)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(4)
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
                                                    .font(.caption3)
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
    }
}
