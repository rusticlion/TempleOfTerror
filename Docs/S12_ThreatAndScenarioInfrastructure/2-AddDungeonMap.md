## Task 2: Add Dungeon Map Screen

**Goal:** Provide a map UI so the player can see explored nodes, connections, and their current location.

**Actions:**
- Create `MapView.swift`:  
  - Draw nodes as circles/squares, connections as lines.
  - Show discovered vs. undiscovered nodes.
  - Highlight current party location.
- Add "Show Map" button to main game UI to present MapView as a modal/sheet.
- Wire MapView to read from GameState’s dungeon model.