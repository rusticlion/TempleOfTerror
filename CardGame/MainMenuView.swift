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
                ContentView(scenario: manifest.id)
            }
            NavigationLink("", isActive: $continueActive) {
                if let vm = continueVM {
                    ContentView(viewModel: vm)
                }
            }
            .hidden()
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

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
