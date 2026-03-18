import SwiftUI

struct CharacterSelectorView: View {
    private enum LayoutMetrics {
        static let groupedMinimumContentWidth: CGFloat = 84
        static let soloScrollMinimumContentWidth: CGFloat = 92
        static let soloFittedMinimumButtonWidth: CGFloat = 80
        static let groupedHorizontalPadding: CGFloat = 10
        static let soloHorizontalPadding: CGFloat = 2
        static let soloSpacing: CGFloat = 10
        static let railHeight: CGFloat = 44
    }

    let characters: [Character]
    @Binding var selectedCharacterID: UUID?
    var movementMode: PartyMovementMode
    var locationNames: [UUID: String] = [:]

    private var showsGroupedLigature: Bool {
        movementMode == .grouped
    }

    private func isSelected(_ character: Character) -> Bool {
        selectedCharacterID == character.id
    }

    private func fittedSoloButtonWidth(in availableWidth: CGFloat) -> CGFloat {
        let itemCount = CGFloat(max(characters.count, 1))
        let totalSpacing = LayoutMetrics.soloSpacing * CGFloat(max(characters.count - 1, 0))
        let contentWidth = max(availableWidth - (LayoutMetrics.soloHorizontalPadding * 2) - totalSpacing, 0)
        return contentWidth / itemCount
    }

    private func usesFittedSoloLayout(in availableWidth: CGFloat) -> Bool {
        guard !showsGroupedLigature else { return false }
        return fittedSoloButtonWidth(in: availableWidth) >= LayoutMetrics.soloFittedMinimumButtonWidth
    }

    @ViewBuilder
    private func characterButton(
        _ character: Character,
        fixedWidth: CGFloat? = nil,
        accessibilityID: String = "characterSelectorButton"
    ) -> some View {
        let selected = isSelected(character)
        let isSoloFittedButton = fixedWidth != nil && !showsGroupedLigature

        Button {
            selectedCharacterID = character.id
        } label: {
            HStack(spacing: 6) {
                Text(character.name)
                    .font(Theme.displayFont(size: 14, weight: .semibold))
                    .foregroundColor(selected ? Theme.gold : Theme.parchmentDark)
                    .lineLimit(1)

                if character.isDefeated {
                    Text("Defeated")
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .foregroundColor(Theme.danger)
                }
            }
            .frame(
                minWidth: showsGroupedLigature ? LayoutMetrics.groupedMinimumContentWidth : (isSoloFittedButton ? nil : LayoutMetrics.soloScrollMinimumContentWidth),
                maxWidth: isSoloFittedButton ? .infinity : nil,
                alignment: .leading
            )
            .padding(.horizontal, showsGroupedLigature ? 12 : 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        showsGroupedLigature
                            ? (selected ? Theme.gold.opacity(0.18) : Color.clear)
                            : (selected ? Theme.gold.opacity(0.18) : Theme.leatherLight.opacity(0.5))
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        selected ? Theme.gold : (showsGroupedLigature ? Color.clear : Theme.inkFaded.opacity(0.3)),
                        lineWidth: selected ? 2 : 1
                    )
            )
        }
        .frame(width: fixedWidth)
        .buttonStyle(.plain)
        .disabled(character.isDefeated)
        .opacity(character.isDefeated ? 0.4 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityID)
    }

    @ViewBuilder
    private func groupedRail() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                    characterButton(
                        character,
                        accessibilityID: "characterSelectorButton_\(index)"
                    )

                    if index < characters.count - 1 {
                        Capsule()
                            .fill(Theme.parchmentDeep.opacity(0.18))
                            .frame(width: 1, height: 24)
                            .padding(.horizontal, 2)
                    }
                }
            }
            .padding(.horizontal, LayoutMetrics.groupedHorizontalPadding)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Theme.leatherLight.opacity(0.55))
            )
            .overlay(
                Capsule()
                    .stroke(Theme.parchmentDeep.opacity(0.22), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private func soloRail(in availableWidth: CGFloat) -> some View {
        if usesFittedSoloLayout(in: availableWidth) {
            HStack(spacing: LayoutMetrics.soloSpacing) {
                ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                    characterButton(
                        character,
                        fixedWidth: fittedSoloButtonWidth(in: availableWidth),
                        accessibilityID: "characterSelectorButton_\(index)"
                    )
                }
            }
            .padding(.horizontal, LayoutMetrics.soloHorizontalPadding)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LayoutMetrics.soloSpacing) {
                    ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                        characterButton(
                            character,
                            accessibilityID: "characterSelectorButton_\(index)"
                        )
                    }
                }
                .padding(.horizontal, LayoutMetrics.soloHorizontalPadding)
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            if showsGroupedLigature {
                groupedRail()
            } else {
                soloRail(in: geo.size.width)
            }
        }
        .frame(height: LayoutMetrics.railHeight)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("partyControlBar")
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
