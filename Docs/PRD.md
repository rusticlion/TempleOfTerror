Dice Delver: A Product Requirements Document
Project: Dice Delver
Platform: iPhone (SwiftUI)
Version: 1.0

1. Overview
Dice Delver is a single-player, rogue-lite dungeon crawl for iOS, built with SwiftUI. It draws inspiration from the high-stakes, trap-filled exploration of the classic D&D module "Tomb of Horrors" and the adventurous spirit of the Indiana Jones franchise. The game will leverage a simplified interpretation of the Forged in the Dark (FitD) tabletop roleplaying game's core mechanics, specifically its dice, stress, and harm systems, which are available under a creative commons license. The gameplay will eschew traditional combat, focusing instead on overcoming environmental hazards, disarming traps, and deciphering cryptic curses.

The game will be structured as a node-based crawl, with players navigating a procedurally generated dungeon. Each run will feature a randomly rolled party of three adventurers, each with unique starting statistics and equipment. The core gameplay loop will revolve around players selecting a character to interact with various "Interactables" within each node, using a chosen statistic to make a roll. A key feature will be the "dice roll projection" which will clearly communicate the potential outcomes (position and effect) to the player before they commit to an action.

2. Goals
To create a compelling and challenging single-player, rogue-lite experience on iOS.
To successfully translate the core tension and player agency of the Forged in the Dark system into a digital format.
To deliver a unique dungeon crawl experience by focusing on non-combat challenges.
To build a robust and scalable architecture in SwiftUI that can be expanded with new content in the future.
To establish a clear and intuitive user interface centered around a "card" metaphor for interactable elements.
3. Target Audience
Players of tabletop roleplaying games, particularly those familiar with Forged in the Dark or other narrative-driven systems.
Fans of rogue-lite and dungeon crawl genres on mobile platforms.
Players who enjoy puzzle-solving and strategic decision-making over fast-paced action.
Admirers of the "Tomb of Horrors" and Indiana Jones style of adventure.
4. Core Mechanics
4.1. The Dice Roll
All actions that involve risk or uncertainty are resolved by a dice roll. The player will assemble a pool of six-sided dice (d6) based on their character's chosen Action Rating. The number of dice in the pool will typically be between one and four. The player rolls the dice and the single highest result determines the outcome:

6: Full Success. The character achieves their goal without any negative consequences.
4-5: Partial Success. The character achieves their goal, but at a cost. This could be taking Stress, suffering Harm, or some other complication.
1-3: Failure. The character fails to achieve their goal and suffers a consequence.
A Critical Success occurs when multiple sixes are rolled. This will result in an enhanced effect or an additional benefit.

4.2. Position & Effect
Before a player commits to a roll, the game will display a "dice roll projection" that communicates the Position and Effect of the action.

Position: This represents the level of risk involved in the action. There are three positions:

Controlled: A failed roll has a minor consequence.
Risky: A failed roll has a standard consequence. This is the default position.
Desperate: A failed roll has a severe consequence.
Effect: This represents the potential level of reward or impact of a successful action. There are three effect levels:

Limited: A less-than-ideal outcome.
Standard: The expected outcome.
Great: A more-than-ideal outcome.
The player's choice of action and the current circumstances will determine the initial Position and Effect.

4.3. Stress
Stress is a resource that players can spend to improve their odds or mitigate negative outcomes. Each character has a Stress track (e.g., 0-9). Players can choose to take Stress to:

Push Themselves: Gain +1d to their dice pool for a roll.
Resist a Consequence: Reduce the severity of a negative outcome. The cost in Stress is determined by a resistance roll.
If a character's Stress track is filled, they suffer Trauma.

4.4. Harm & Trauma
Harm represents physical and mental injuries. Harm comes in levels of severity:

Level 1: Lesser (e.g., "Shaken," "Bruised")
Level 2: Moderate (e.g., "Gashed Arm," "Concussion")
Level 3: Severe (e.g., "Broken Leg," "Cursed")
Each level of Harm imposes a penalty on the character's actions. If a character suffers Harm when all slots of that severity are full, the Harm is upgraded to the next level. If a character with a Severe Harm takes another, they are taken out of the current run.

Trauma is a permanent negative trait a character gains when their Stress track is filled. Each Trauma condition will have a specific mechanical and narrative effect. Accumulating a certain number of Traumas will force a character's retirement from the party.

5. Game Structure
5.1. The Rogue-lite Loop
Party Generation: The player begins a new run with a randomly generated party of three characters. Each character will have a "class" with unique starting stats and gear.
Dungeon Crawl: The player navigates the node-based dungeon.
Interactables: Within each node, the player will encounter Interactables presented as cards.
Action & Resolution: The player chooses a character and an action to interact with the card, leading to a dice roll.
Consequences & Rewards: The outcome of the roll determines the rewards (e.g., new paths, loot, information) and consequences (e.g., Stress, Harm, environmental changes).
Perma-death (for the run): Characters taken out by Harm are gone for the remainder of the run. If all characters are defeated, the run ends.
Meta-Progression: Successful runs will unlock new character classes, starting gear, and potentially new dungeon types for future runs.
5.2. The Dungeon: A Node Crawl
The dungeon will be represented as a map of interconnected nodes. The player's party will occupy a single node at a time. Connections between nodes may be initially hidden or locked, requiring successful checks to reveal or open them. Each node will contain one or more "Interactables."

6. User Interface & User Experience (UI/UX)
6.1. The "Card" Metaphor
The primary visual metaphor for interacting with the game world will be through "cards." Each Interactable (e.g., a trapped chest, a mysterious lever, a cryptic riddle) will be presented as a card. The card will contain:

A title and descriptive text.
An illustration of the Interactable.
A list of possible actions a player can take, along with the corresponding stat to be used.
Tapping on an action will bring up the "dice roll projection" view, showing the Position and Effect before the player confirms the roll.

6.2. Main Screens
Main Menu: Start New Run, Continue Run, Unlocks/Meta-Progression, Settings.
Party View: Shows the status of the three party members, including their stats, Stress, Harm, and equipment.
Dungeon Map View: Displays the node map, the party's current location, and known connections.
Node View: The primary gameplay screen, displaying the Interactable cards for the current node.
Dice Roll Projection View: A modal view that appears before a roll, detailing the Position, Effect, and any modifiers.
7. Content
7.1. Character Classes
Each class will have a unique set of starting Action Ratings and a special ability. Examples include:

The Archaeologist: High in Study and Tinker. Special Ability: Once per run, can automatically succeed at a roll to decipher ancient texts.
The Brawler: High in Wreck and Finesse. Special Ability: Can take an extra level of Harm before being taken out.
The Mystic: High in Attune and Survey. Special Ability: Can spend Stress to have a vision about a nearby node.
7.2. Action Ratings
Action Ratings will be simplified from the full FitD set to better suit the non-combat focus. Examples include:

Study: Deciphering texts, understanding mechanisms.
Survey: Spotting hidden dangers, finding secret passages.
Tinker: Disarming traps, repairing gear.
Finesse: Delicate movements, sleight of hand.
Wreck: Applying brute force.
Attune: Sensing supernatural energies, resisting curses.
7.3. Interactables
Interactables will be the core of the gameplay. They will be designed to present interesting choices and challenges that can be overcome in multiple ways, depending on the chosen character and action. Examples:

A Pressure Plate: Can be Tinkered with to disarm, Finessed across to avoid, or Wrecked to trigger from a safe distance.
A Cursed Idol: Can be Attuned with to understand the curse, Studied to find a weakness, or Wrecked from afar.
8. Technical Considerations
Engine: SwiftUI. The declarative nature of SwiftUI is well-suited for the card-based UI and displaying dynamic information like the dice roll projection.
Architecture: A Model-View-ViewModel (MVVM) architecture is recommended to separate the game logic from the UI.
Data Persistence: Player progress, unlocks, and run state will be saved locally using Swift's Codable and UserDefaults or a more robust solution like Core Data if necessary.
Procedural Generation: The dungeon layout, node connections, and Interactable placement will be procedurally generated at the start of each run to enhance replayability.
9. Future Development
Content Expansion: New character classes, dungeon types, Interactables, and enemy factions (though not in a traditional combat sense) can be added as updates.
9.1. The "Clocks" Mechanic (Addendum to PRD)
Clocks are visual progress trackers used for complex or ongoing challenges that cannot be resolved with a single action. Examples include: "The Guards' Suspicion," "Disarming the Complex Trap," or "Deciphering the Ancient Mural."

Structure: A clock is represented as a segmented circle (e.g., 4, 6, or 8 segments).
Progression: Successful actions can fill in one or more segments of a clock. The Effect level of the roll determines how many segments are filled (e.g., Limited = 1, Standard = 2, Great = 3).
Complications: Partial successes or failures might add segments to a negative clock (e.g., "Reinforcements Arrive") or introduce a new, linked clock.
Resolution: When a clock is completely filled, the event it represents comes to pass. This can be positive (the trap is disarmed) or negative (the alarm is raised).
UI Implementation: A dedicated, non-intrusive view will display all currently active clocks, allowing the player to track ongoing progress and threats at a glance.
Leaderboards: Integration with Game Center for high score tracking.
iCloud Sync: Allowing players to continue their runs across multiple devices.
Accessibility: Implementing features like Dynamic Type and VoiceOver to ensure the game is playable by a wider audience.