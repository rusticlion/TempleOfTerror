Task 3: Building the UI (The "View")
Action: Create the most basic possible views to display the state and trigger actions. Use placeholder UI and minimal styling for now.

PartyStatusView.swift:

Displays a list of the characters.
For each character, shows their name, stress, and harm levels.
This view will read from the GameViewModel.
ClocksView.swift:

Displays a list of active clocks.
For each clock, shows its name and a simple text representation of its progress (e.g., "2 / 6").
ContentView.swift (Main Game Screen):

Instantiate the @StateObject var viewModel = GameViewModel().
Display the PartyStatusView and ClocksView.
Display a single, hardcoded "Interactable Card" for a "Trapped Pedestal".
The card will have buttons for its availableActions (e.g., "Tinker with it," "Study the Glyphs").
Tapping an action button will:
Present a simple Alert or modal sheet showing the output from viewModel.calculateProjection().
The alert will have a "Roll" button that calls viewModel.performAction().