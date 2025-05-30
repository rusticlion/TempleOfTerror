import SwiftUI

struct MainMenuView: View {
    @State private var showingScenarioSelect = false
    @State private var availableScenarios: [ScenarioManifest] = ContentLoader.availableScenarios()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Text("Temple of Terror")
                    .font(.largeTitle)
                    .bold()

                Button("Start New Game") {
                    if let scenario = availableScenarios.first(where: { $0.id == "tomb" }) ?? availableScenarios.first {
                        path.append(scenario)
                    }
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
            .navigationDestination(for: ScenarioManifest.self) { manifest in
                ContentView(scenario: manifest.id)
            }
            .sheet(isPresented: $showingScenarioSelect) {
                ScenarioSelectView(available: availableScenarios) { manifest in
                    path.append(manifest)
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
