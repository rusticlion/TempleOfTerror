import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?
    var movementMode: PartyMovementMode

    private func isSelected(_ character: Character) -> Bool {
        selectedCharacterID == character.id
    }

    @ViewBuilder
    private func characterButton(_ character: Character) -> some View {
        let selected = isSelected(character)
        Button {
            selectedCharacterID = character.id
        } label: {
            Text(character.name)
                .font(Theme.displayFont(size: 14, weight: .semibold))
                .foregroundColor(selected ? Theme.gold : Theme.parchmentDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? Theme.gold.opacity(0.15) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(selected ? Theme.gold : Theme.inkFaded.opacity(0.3), lineWidth: selected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(character.isDefeated)
        .opacity(character.isDefeated ? 0.4 : 1)
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
                HStack(spacing: 10) {
                    ForEach(characters) { character in
                        characterButton(character)
                    }
                }
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
