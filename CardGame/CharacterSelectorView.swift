import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?
    var movementMode: PartyMovementMode
    var locationNames: [UUID: String] = [:]

    private func isSelected(_ character: Character) -> Bool {
        selectedCharacterID == character.id
    }

    @ViewBuilder
    private func characterButton(_ character: Character) -> some View {
        let selected = isSelected(character)
        let locationName = locationNames[character.id]
        let isSolo = movementMode == .solo

        Button {
            selectedCharacterID = character.id
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(character.name)
                    .font(Theme.displayFont(size: 14, weight: .semibold))
                    .foregroundColor(selected ? Theme.gold : Theme.parchmentDark)
                    .lineLimit(1)

                if character.isDefeated {
                    Text("Defeated")
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .foregroundColor(Theme.danger)
                } else if isSolo, let locationName {
                    Text(locationName)
                        .font(Theme.systemFont(size: 10, weight: .medium))
                        .foregroundColor(selected ? Theme.parchment : Theme.inkFaded)
                        .lineLimit(1)
                }
            }
            .frame(minWidth: isSolo ? 112 : nil, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, isSolo ? 10 : 8)
            .background(
                RoundedRectangle(cornerRadius: isSolo ? 12 : 999)
                    .fill(selected ? Theme.gold.opacity(isSolo ? 0.18 : 0.15) : Theme.leatherLight.opacity(isSolo ? 0.45 : 0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: isSolo ? 12 : 999)
                    .stroke(selected ? Theme.gold : Theme.inkFaded.opacity(0.3), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(character.isDefeated)
        .opacity(character.isDefeated ? 0.4 : 1)
        .accessibilityIdentifier("characterSelectorButton")
    }

    var body: some View {
        Group {
            if movementMode == .grouped {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(characters) { character in
                            characterButton(character)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 10, alignment: .top)
                    ],
                    alignment: .leading,
                    spacing: 10
                ) {
                    ForEach(characters) { character in
                        characterButton(character)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CharacterSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSelectorView(characters: [
            Character(id: UUID(), name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3]),
            Character(id: UUID(), name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Wreck": 2])
        ], selectedCharacterID: .constant(nil), movementMode: .grouped)
    }
}
