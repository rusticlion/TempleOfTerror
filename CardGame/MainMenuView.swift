import SwiftUI

struct MainMenuView: View {
    @State private var showingScenarioSelect = false
    @State private var startScenario: ScenarioManifest?
    @State private var availableScenarios: [ScenarioManifest] = ContentLoader.availableScenarios()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Temple of Terror")
                    .font(.largeTitle)
                    .bold()

                Button("Start New Game") {
                    startScenario = availableScenarios.first { $0.id == "tomb" } ?? availableScenarios.first
                }
                .buttonStyle(.borderedProminent)

                Button("Continue") { }
                    .disabled(true)

                Button("Scenario Select") {
                    showingScenarioSelect = true
                }
                .buttonStyle(.bordered)

                Button("Settings") { }
                    .disabled(true)
            }
            .padding()
            .navigationDestination(item: $startScenario) { manifest in
                ContentView(scenario: manifest.id)
            }
            .sheet(isPresented: $showingScenarioSelect) {
                ScenarioSelectView(available: availableScenarios) { manifest in
                    startScenario = manifest
                    showingScenarioSelect = false
                }
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
                    Text(scenario.title).font(.headline)
                    Text(scenario.description).font(.subheadline)
                }
                .onTapGesture {
                    onSelect(scenario)
                    dismiss()
                }
            }
            .navigationTitle("Scenarios")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
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
