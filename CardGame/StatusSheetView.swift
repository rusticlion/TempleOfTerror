import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selectedCharacterID: UUID?
    @State private var inspectedCharacter: Character?
    @Environment(\.dismiss) private var dismiss

    private struct RoomGroup: Identifiable {
        let id: String
        let roomName: String
        let characters: [Character]
        let isCurrent: Bool
        let hasThreat: Bool
        let isAlone: Bool
    }

    private struct StateChip: Identifiable {
        let id = UUID()
        let text: String
        let foreground: Color
        let fill: Color
    }

    private var visibleClocks: [GameClock] {
        viewModel.gameState.activeClocks.filter { $0.progress > 0 }
    }

    private var activeCharacters: [Character] {
        viewModel.gameState.party.filter { !$0.isDefeated }
    }

    private var selectedLocationKey: String? {
        guard let selectedCharacterID else { return nil }
        return viewModel.gameState.characterLocations[selectedCharacterID.uuidString]?.uuidString
    }

    private var roomGroups: [RoomGroup] {
        let grouped = Dictionary(grouping: activeCharacters) { character in
            viewModel.gameState.characterLocations[character.id.uuidString]?.uuidString ?? "unknown"
        }

        return grouped
            .map { key, characters in
                let roomName = characters
                    .compactMap { viewModel.getNodeName(for: $0.id) }
                    .first ?? "Unknown Location"
                let sortedCharacters = characters.sorted { lhs, rhs in
                    if lhs.id == selectedCharacterID { return true }
                    if rhs.id == selectedCharacterID { return false }
                    return lhs.name < rhs.name
                }
                let hasThreat = sortedCharacters.contains { viewModel.isCharacterEngaged($0.id) }

                return RoomGroup(
                    id: key,
                    roomName: roomName,
                    characters: sortedCharacters,
                    isCurrent: key == selectedLocationKey,
                    hasThreat: hasThreat,
                    isAlone: sortedCharacters.count == 1 && grouped.count > 1
                )
            }
            .sorted { lhs, rhs in
                if lhs.isCurrent != rhs.isCurrent {
                    return lhs.isCurrent
                }
                return lhs.roomName.localizedCaseInsensitiveCompare(rhs.roomName) == .orderedAscending
            }
    }

    private func roomChip(for group: RoomGroup) -> StateChip? {
        if group.hasThreat {
            return StateChip(text: "Threat", foreground: .white, fill: Theme.danger.opacity(0.85))
        }
        if group.isAlone {
            return StateChip(text: "Alone", foreground: Theme.ink, fill: Theme.gold.opacity(0.8))
        }
        if group.isCurrent {
            return StateChip(text: "Current", foreground: Theme.ink, fill: Theme.success.opacity(0.8))
        }
        return nil
    }

    private func stateChips(for character: Character, in group: RoomGroup) -> [StateChip] {
        var chips: [StateChip] = []

        if character.id == selectedCharacterID {
            chips.append(StateChip(text: "Active", foreground: Theme.ink, fill: Theme.success.opacity(0.82)))
        }

        if viewModel.isCharacterEngaged(character.id) {
            chips.append(StateChip(text: "Engaged", foreground: .white, fill: Theme.danger.opacity(0.82)))
        } else if group.isAlone {
            chips.append(StateChip(text: "Alone", foreground: Theme.ink, fill: Theme.gold.opacity(0.78)))
        } else if character.id != selectedCharacterID {
            chips.append(StateChip(text: "Ready", foreground: Theme.parchmentDark, fill: Theme.leatherLight.opacity(0.8)))
        }

        return Array(chips.prefix(2))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Party By Room")
                            .font(Theme.displayFont(size: 22, weight: .semibold))
                            .foregroundColor(Theme.parchment)

                        ForEach(roomGroups) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                roomHeader(for: group)

                                ForEach(group.characters) { character in
                                    explorerRow(for: character, in: group)
                                }
                            }
                        }
                    }

                    if !visibleClocks.isEmpty {
                        Theme.InkDivider()

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Pressure")
                                .font(Theme.displayFont(size: 22, weight: .semibold))
                                .foregroundColor(Theme.parchment)

                            ForEach(visibleClocks) { clock in
                                CondensedClockRow(clock: clock)
                            }
                        }
                    }

                    Text("Tap an explorer to review their full sheet. Change the acting explorer from the selector bar in the main view.")
                        .font(Theme.bodyFont(size: 13, italic: true))
                        .foregroundColor(Theme.inkFaded)
                }
                .padding(20)
            }
            .background(Theme.bgWarm)
            .presentationBackground(Theme.bgWarm)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.leather, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Expedition")
                        .font(Theme.displayFont(size: 22, weight: .semibold))
                        .foregroundColor(Theme.parchment)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.parchment)
                }
            }
        }
        .sheet(item: $inspectedCharacter) { character in
            CharacterDetailSheetView(
                character: character,
                locationName: viewModel.getNodeName(for: character.id),
                harmFamilies: viewModel.harmFamilies
            )
            .presentationDetents([.medium, .large])
        }
        .accessibilityIdentifier("expeditionDrawer")
    }

    @ViewBuilder
    private func roomHeader(for group: RoomGroup) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("\(group.roomName) (\(group.characters.count))")
                .font(Theme.displayFont(size: 18, weight: .semibold))
                .foregroundColor(Theme.parchment)

            Spacer(minLength: 10)

            if let chip = roomChip(for: group) {
                InRunStateBadge(
                    text: chip.text,
                    foreground: chip.foreground,
                    fill: chip.fill
                )
            }
        }
    }

    private func explorerRow(for character: Character, in group: RoomGroup) -> some View {
        Button {
            inspectedCharacter = character
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(character.name)
                        .font(Theme.displayFont(size: 18, weight: .semibold))
                        .foregroundColor(Theme.parchment)
                        .lineLimit(1)

                    Spacer(minLength: 10)

                    Text("Stress \(character.stress) / 9")
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.parchmentDark)

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                }

                HStack(alignment: .center, spacing: 8) {
                    Text(character.characterClass)
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                        .textCase(.uppercase)
                        .tracking(0.7)

                    Spacer(minLength: 8)

                    InRunStateBadge(
                        text: character.coarseHarmStateLabel,
                        foreground: character.coarseHarmTint == Theme.gold ? Theme.ink : .white,
                        fill: character.coarseHarmTint.opacity(0.82)
                    )

                    ForEach(stateChips(for: character, in: group)) { chip in
                        InRunStateBadge(
                            text: chip.text,
                            foreground: chip.foreground,
                            fill: chip.fill
                        )
                    }
                }

                ActionRatingsLine(character: character, fontSize: 12, foreground: Theme.parchmentDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.leatherLight.opacity(character.id == selectedCharacterID ? 0.8 : 0.58))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(character.id == selectedCharacterID ? Theme.gold.opacity(0.8) : Theme.parchmentDeep.opacity(0.2), lineWidth: character.id == selectedCharacterID ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("expeditionExplorerRow")
    }
}

struct StatusSheetView_Previews: PreviewProvider {
    static var previews: some View {
        StatusSheetView(viewModel: GameViewModel(), selectedCharacterID: .constant(nil))
    }
}
