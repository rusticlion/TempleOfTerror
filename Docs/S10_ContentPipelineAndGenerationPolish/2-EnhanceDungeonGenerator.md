Task 2: Enhance DungeonGenerator.swift
Now we make the generator smarter and use our new content.

Action: Refactor DungeonGenerator.generate(level: Int) to incorporate more sophisticated logic.
Implementation Plan:
Node Theming/Tagging (Optional but Recommended):
In your MapNode model, consider adding var theme: String? or var tags: [String]?.
The DungeonGenerator can then assign themes (e.g., "corridor," "trap_chamber," "shrine," "antechamber") to nodes as it creates them.
Content Selection based on Theme:
When populating a node, filter content.interactableTemplates based on the node's theme/tags. This makes room content more logical. (e.g., a "trap_chamber" is more likely to get template_pressure_plate).
Clock Generation:
Define a few placeholder clock names/segment counts (e.g., in DungeonGenerator or a new simple JSON like clocks_templates.json).
At the start of generate(), randomly select 1-2 of these and add them to the GameState.activeClocks.
Dynamic Connection Locking & Unlocking:
When creating connections, randomly decide for some of them to set isUnlocked = false.
Crucially: For each locked connection, ensure the generator also places an interactable somewhere in the dungeon (perhaps in a preceding or adjacent node) that has an unlockConnection consequence in its outcomes targeting that specific locked connection's fromNodeID and toNodeID. This requires the generator to keep track of locked doors and the interactables that can unlock them.
Pathfinding Check (Simplified): To ensure the dungeon is solvable, always ensure there's at least one path from startingNodeID to a designated "exit node" (e.g., the last node in your linear generation) that is either initially unlocked or has its unlocking interactable placed in an accessible location. For now, you could just ensure the main chain of nodes is always unlockable.
Treasure Distribution:
Ensure your new Interactable templates with gainTreasure consequences are part of the pool the generator picks from. The current random selection should handle this if the templates exist.
Varying Node Count & Branching (Stretch Goal):
Instead of a purely linear nodeCount, consider a simple branching algorithm. For example, some nodes could have two forward connections instead of one, leading to small dead-end branches with special rewards or dangers.
Updated GameViewModel.startNewRun():
No major changes expected here other than potentially passing more parameters to generator.generate() if you add complexity like a "dungeon seed" or "target difficulty." The primary work is within the DungeonGenerator itself.