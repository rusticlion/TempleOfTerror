Task 2: Reorganize Status Views into a "Party Sheet"
The PartyStatusView and ClocksView provide crucial information, but they take up a lot of permanent screen real estate. Let's move them into a secondary, accessible sheet that the player can pull up when needed. This declutters the main view, focusing the player on the current node's interactables.

Action: Combine PartyStatusView and ClocksView into a new StatusSheetView.swift.
Action: Add a persistent "Party" button to ContentView that presents this sheet.
StatusSheetView.swift (New File)

Swift

import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            PartyStatusView(viewModel: viewModel)
            Divider()
            ClocksView(viewModel: viewModel)
            Spacer()
        }
        .padding()
    }
}
ContentView.swift (Sheet Implementation)

Swift

struct ContentView: View {
    // ...
    @State private var showingStatusSheet = false // New state to control the sheet

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ... HeaderView ...

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // The PartyStatusView and ClocksView are REMOVED from here
                        
                        // ... Interactables and NodeConnections ...
                    }
                    .padding()
                }
            }
            // ...

            // Add a floating button to show the status sheet
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingStatusSheet.toggle()
                    } label: {
                        Image(systemName: "person.3.fill")
                        Text("Party")
                    }
                    .padding()
                    .background(.thinMaterial, in: Capsule())
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingStatusSheet) {
            StatusSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large]) // Allow a half-sheet
        }
        //...
    }
}