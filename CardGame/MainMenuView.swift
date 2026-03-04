import SwiftUI

struct MainMenuView: View {
    @State private var showingScenarioSelect = false
    @State private var availableScenarios: [ScenarioManifest] = ContentLoader.availableScenarios()
        .filter { !$0.id.hasPrefix("test_") }
    @State private var path = NavigationPath()
    @State private var continueVM: GameViewModel?
    @State private var continueActive = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 16) {
                    Spacer(minLength: 40)

                    Text("Dice Delver")
                        .font(Theme.displayFont(size: 36))
                        .foregroundColor(Theme.parchment)

                    LinearGradient(
                        colors: [.clear, Theme.goldDim, Theme.goldDim, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 48)

                    Spacer(minLength: 12)

                    Button {
                        if let scenario = availableScenarios.first(where: { $0.id == "tomb" }) ?? availableScenarios.first {
                            path.append(scenario)
                        }
                    } label: {
                        Text("Start New Game")
                            .font(Theme.displayFont(size: 20, weight: .semibold))
                            .foregroundColor(Theme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Theme.gold, Theme.goldDim],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: Theme.gold.opacity(0.3), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)

                    Button {
                        let vm = GameViewModel()
                        if vm.loadGame() {
                            continueVM = vm
                            continueActive = true
                        }
                    } label: {
                        Text("Continue")
                            .font(Theme.displayFont(size: 18, weight: .semibold))
                            .foregroundColor(Theme.parchment)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!GameViewModel.saveExists)
                    .opacity(GameViewModel.saveExists ? 1 : 0.5)

                    Button {
                        showingScenarioSelect = true
                    } label: {
                        Text("Scenario Select")
                            .font(Theme.displayFont(size: 18, weight: .semibold))
                            .foregroundColor(Theme.parchment)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button("Settings") { }
                        .font(Theme.displayFont(size: 16, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                .foregroundColor(Theme.inkFaded.opacity(0.5))
                        )
                        .buttonStyle(.plain)
                        .disabled(true)

                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .navigationDestination(for: ScenarioManifest.self) { manifest in
                PartySetupView(manifest: manifest)
            }
            .navigationDestination(isPresented: $continueActive) {
                if let vm = continueVM {
                    ContentView(viewModel: vm)
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showingScenarioSelect) {
                ScenarioSelectView(available: availableScenarios) { manifest in
                    path.append(manifest)
                    showingScenarioSelect = false
                }
                .presentationBackground(Theme.bgWarm)
            }
        }
    }
}

private struct ScenarioSelectView: View {
    var available: [ScenarioManifest]
    var onSelect: (ScenarioManifest) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(available, id: \.id) { scenario in
                VStack(alignment: .leading) {
                    Text(scenario.title)
                        .font(Theme.displayFont(size: 18, weight: .semibold))
                        .foregroundColor(Theme.ink)
                    Text(scenario.description)
                        .font(Theme.bodyFont(size: 14))
                        .foregroundColor(Theme.inkLight)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .listRowBackground(Theme.parchment.opacity(0.9))
                .onTapGesture {
                    onSelect(scenario)
                    dismiss()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bgWarm)
            .navigationTitle("Scenarios")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(Theme.systemFont(size: 14, weight: .semibold))
                        .foregroundColor(Theme.parchment)
                }
            }
        }
    }
}

private struct PartySetupView: View {
    let manifest: ScenarioManifest

    @State private var selectedArchetypeIDs: [String]
    @State private var pendingPlan: PartyBuildPlan?
    @State private var startActive = false

    private let content: ContentLoader
    private let partyBuilder: PartyBuilderService

    init(manifest: ScenarioManifest) {
        self.manifest = manifest
        let content = ContentLoader(scenario: manifest.id)
        self.content = content
        self.partyBuilder = PartyBuilderService(content: content)

        let partySize = max(manifest.partySize ?? 3, 1)
        let nativeIDs = manifest.nativeArchetypeIDs ?? content.archetypeTemplates.map(\.id)
        let fallbackIDs = nativeIDs.count >= partySize
            ? nativeIDs
            : content.archetypeTemplates.map(\.id)
        _selectedArchetypeIDs = State(initialValue: Array(fallbackIDs.shuffled().prefix(partySize)))
    }

    private var partySize: Int {
        max(manifest.partySize ?? 3, 1)
    }

    private var availableArchetypes: [ArchetypeDefinition] {
        partyBuilder.availableArchetypes(nativeArchetypeIDs: manifest.nativeArchetypeIDs ?? [])
    }

    private var selectedArchetypes: [ArchetypeDefinition] {
        selectedArchetypeIDs.compactMap { id in
            availableArchetypes.first(where: { $0.id == id })
        }
    }

    private var canStart: Bool {
        selectedArchetypes.count == partySize
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(manifest.description)
                    .font(Theme.bodyFont(size: 16, italic: true))
                    .foregroundColor(Theme.inkLight)
                    .lineSpacing(4)

                HStack(spacing: 10) {
                    SetupPill(label: "Party Size", value: "\(partySize)")
                    SetupPill(label: "Roster", value: "\(availableArchetypes.count) native")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected Party")
                        .font(Theme.displayFont(size: 22, weight: .semibold))
                        .foregroundColor(Theme.ink)

                    Text("Choose \(partySize) archetypes. Tap a selected card to remove it; tapping a new card when full replaces the oldest pick.")
                        .font(Theme.bodyFont(size: 14))
                        .foregroundColor(Theme.inkLight)

                    if selectedArchetypes.isEmpty {
                        Text("No archetypes available for this scenario.")
                            .font(Theme.bodyFont(size: 14, italic: true))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        ForEach(Array(selectedArchetypes.enumerated()), id: \.element.id) { index, archetype in
                            SelectedArchetypeRow(
                                slotNumber: index + 1,
                                archetype: archetype
                            )
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        shuffleSelection()
                    } label: {
                        Text("Shuffle Picks")
                            .font(Theme.systemFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.parchment)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Theme.ink)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(availableArchetypes.count < partySize)
                    .opacity(availableArchetypes.count < partySize ? 0.5 : 1)

                    Text("\(selectedArchetypes.count)/\(partySize) selected")
                        .font(Theme.systemFont(size: 13, weight: .medium))
                        .foregroundColor(Theme.inkFaded)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Archetypes")
                        .font(Theme.displayFont(size: 22, weight: .semibold))
                        .foregroundColor(Theme.ink)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(availableArchetypes) { archetype in
                            let selectionIndex = selectedArchetypeIDs.firstIndex(of: archetype.id)
                            Button {
                                toggleSelection(for: archetype.id)
                            } label: {
                                ArchetypeCard(
                                    archetype: archetype,
                                    selectionNumber: selectionIndex.map { $0 + 1 },
                                    isSelected: selectionIndex != nil
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    pendingPlan = PartyBuildPlan(
                        partySize: partySize,
                        nativeArchetypeIDs: manifest.nativeArchetypeIDs ?? availableArchetypes.map(\.id),
                        selectedArchetypeIDs: selectedArchetypeIDs,
                        mode: .manualSelection
                    )
                    startActive = true
                } label: {
                    Text("Begin Scenario")
                        .font(Theme.displayFont(size: 20, weight: .semibold))
                        .foregroundColor(Theme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Theme.gold, Theme.goldDim],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!canStart)
                .opacity(canStart ? 1 : 0.55)
            }
            .padding(20)
        }
        .background(Theme.bgWarm)
        .navigationTitle(manifest.title)
        .navigationDestination(isPresented: $startActive) {
            if let pendingPlan {
                ContentView(scenario: manifest.id, partyPlan: pendingPlan)
            } else {
                EmptyView()
            }
        }
    }

    private func toggleSelection(for archetypeID: String) {
        if let index = selectedArchetypeIDs.firstIndex(of: archetypeID) {
            selectedArchetypeIDs.remove(at: index)
            return
        }

        if selectedArchetypeIDs.count >= partySize {
            selectedArchetypeIDs.removeFirst()
        }
        selectedArchetypeIDs.append(archetypeID)
    }

    private func shuffleSelection() {
        let candidateIDs = availableArchetypes.map(\.id)
        selectedArchetypeIDs = Array(candidateIDs.shuffled().prefix(partySize))
    }
}

private struct SelectedArchetypeRow: View {
    let slotNumber: Int
    let archetype: ArchetypeDefinition

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(slotNumber)")
                .font(Theme.systemFont(size: 13, weight: .bold))
                .foregroundColor(Theme.parchment)
                .frame(width: 24, height: 24)
                .background(Theme.ink)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(archetype.name)
                    .font(Theme.displayFont(size: 18, weight: .semibold))
                    .foregroundColor(Theme.ink)
                Text(archetype.description)
                    .font(Theme.bodyFont(size: 13))
                    .foregroundColor(Theme.inkLight)
                Text(actionSummary(for: archetype))
                    .font(Theme.systemFont(size: 12, weight: .medium))
                    .foregroundColor(Theme.inkFaded)
            }

            Spacer()
        }
        .padding(14)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)
        )
    }
}

private struct ArchetypeCard: View {
    let archetype: ArchetypeDefinition
    let selectionNumber: Int?
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(archetype.name)
                    .font(Theme.displayFont(size: 17, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                if let selectionNumber {
                    Text("\(selectionNumber)")
                        .font(Theme.systemFont(size: 12, weight: .bold))
                        .foregroundColor(Theme.parchment)
                        .frame(width: 22, height: 22)
                        .background(Theme.ink)
                        .clipShape(Circle())
                }
            }

            Text(archetype.description)
                .font(Theme.bodyFont(size: 13))
                .foregroundColor(Theme.inkLight)
                .fixedSize(horizontal: false, vertical: true)

            Text(actionSummary(for: archetype))
                .font(Theme.systemFont(size: 12, weight: .medium))
                .foregroundColor(Theme.inkFaded)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            if isSelected {
                Theme.parchment.opacity(0.98)
            } else {
                Theme.cardBackground
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected ? Theme.goldDim : Theme.parchmentDeep.opacity(0.35),
                    lineWidth: isSelected ? 2 : 1
                )
        )
    }
}

private struct SetupPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.systemFont(size: 11, weight: .semibold))
                .foregroundColor(Theme.inkFaded)
                .textCase(.uppercase)
                .tracking(0.6)
            Text(value)
                .font(Theme.displayFont(size: 16, weight: .semibold))
                .foregroundColor(Theme.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
        )
    }
}

private func actionSummary(for archetype: ArchetypeDefinition) -> String {
    archetype.defaultActions
        .sorted { lhs, rhs in
            if lhs.value == rhs.value {
                return lhs.key < rhs.key
            }
            return lhs.value > rhs.value
        }
        .map { "\($0.key) \($0.value)" }
        .joined(separator: "  •  ")
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
