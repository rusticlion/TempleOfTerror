## Task 5: Save & Load System

**Goal:** Persist and restore game state, allowing “Continue” after quitting.

**Actions:**
- Add serialization helpers to GameState (Codable).
- Implement `saveGame()` and `loadGame()` methods using UserDefaults or local file storage.
- Save after significant actions, auto-save at game over, and on quit.
- "Continue" loads saved state and resumes scenario.
- Main menu disables Continue if no save exists.