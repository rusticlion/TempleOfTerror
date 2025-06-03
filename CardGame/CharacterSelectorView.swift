import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?
    var movementMode: PartyMovementMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Character")
                .font(.headline)

            if movementMode == .grouped {
                Picker("Select Character", selection: $selectedCharacterID) {
                    ForEach(characters) { character in
                        Text(character.name).tag(character.id as UUID?)
                    }
                }
                .pickerStyle(.segmented)
            } else {
                HStack(spacing: 12) {
                    ForEach(characters) { character in
                        Button {
                            selectedCharacterID = character.id
                        } label: {
                            Text(character.name)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(selectedCharacterID == character.id ? Color.accentColor.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
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
