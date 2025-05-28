import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Character")
                .font(.headline)
            Picker("Select Character", selection: $selectedCharacterID) {
                ForEach(characters) { character in
                    Text(character.name).tag(character.id as UUID?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct CharacterSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSelectorView(characters: [
            Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3]),
            Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Wreck": 2])
        ], selectedCharacterID: .constant(nil))
    }
}
