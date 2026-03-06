Dice Delver: Product Requirements Document
Project: Dice Delver
Platform: iPhone (SwiftUI)
Version: 1.0

## 1. Overview

Dice Delver is a mobile anthology of hazardous expedition crawls. Each scenario drops a freshly generated party into a distinct authored expedition, such as a trap-laden pulp tomb, a haunted house sliding toward cosmic horror, or a compromised freighter concealing a grotesque secret. Rather than centering full procedural generation or traditional combat, the game is built around high-stakes Forged in the Dark-inspired risk management: choosing who acts, what action they take, what risks they accept, when they push for better odds, and when they resist consequences.

The long-term product is a growing library of authored scenarios united by the theme of hazardous expeditions. Replayability comes first from party generation and branching authored outcomes, with light scenario-local randomization as an optional enhancement rather than a defining pillar.

## 2. Product Vision

Dice Delver is an anthology product rather than a single monolithic campaign. Each scenario should feel like a self-contained expedition with its own tone, setting, native archetype pool, hazards, authored map or structure, and likely multiple endings, while sharing a consistent rules language built around action rolls, stress, harm, clocks, and consequences.

The game should support sharply different genres while remaining coherent under the same thematic umbrella. The connective tissue is not setting; it is the fantasy of leading a vulnerable expedition through an environment full of danger, uncertainty, and irreversible consequences.

## 3. Goals

- Deliver a compelling mobile experience centered on FitD-style risk management rather than combat tactics.
- Establish Dice Delver as a genre-spanning anthology of hazardous expeditions.
- Build a robust, scalable, data-driven architecture that supports ongoing scenario releases over time.
- Make branching narrative consequences and multiple likely endings a core part of the product identity.
- Ensure party composition and split-up-versus-stick-together decisions are meaningfully impactful.
- Ship a scenario catalog and entitlement model that supports included scenarios, paid scenarios, and future expansion through individual purchases.

## 4. Target Audience

- Players of tabletop RPGs, especially those familiar with Forged in the Dark or other narrative-forward systems.
- Players who enjoy authored adventure, horror, mystery, and expedition fiction on mobile.
- Players who prefer tension, consequence, and resource management over twitch action or combat-heavy tactics.
- Fans of pulp archaeology adventure, haunted-house horror, cosmic horror, survival horror, and adjacent genre fiction.
- Players who are open to premium, scenario-based content rather than an endless procedural live-service loop.

## 5. Core Design Pillars

### 5.1. FitD Risk Management

The primary pleasure of play is evaluating danger, choosing who should act, judging position and effect, spending resources to improve odds, and deciding whether consequences are worth resisting.

### 5.2. Branching Authored Narrative

Scenarios are expected to branch through authored state, events, interactable changes, clocks, and endings. A scenario may theoretically have a forced ending, but multiple likely outcomes should be the norm.

### 5.3. Party-Level Decision Making

The game should make "who handles this?" and "do we split up?" feel consequential. Party members are not interchangeable dice pools; they are the player's main lens for managing risk.

### 5.4. Scenario-Native Identity

Each scenario should feel authored for its setting. Archetypes, hazards, treasures, modifiers, and progression should reflect the scenario's fiction rather than a global generic roster.

### 5.5. Anthology Breadth

The product should support sharply different tones and genres while remaining coherent under the shared theme of hazardous expeditions.

## 6. Core Mechanics

### 6.1. The Dice Roll

All actions that involve risk or uncertainty are resolved by assembling a pool of six-sided dice (d6) based on the acting character's chosen Action Rating, then reading the highest result.

- `6`: Full Success. The character achieves their goal without a negative consequence.
- `4-5`: Partial Success. The character achieves their goal, but at a cost.
- `1-3`: Failure. The character fails and suffers a consequence.
- Multiple sixes: Critical Success. The action gains an enhanced result, usually expressed as improved effect or an additional authored benefit.

### 6.2. Position and Effect

Before a player commits to a roll, the game displays a projection showing Position and Effect.

- Position communicates risk severity: `Controlled`, `Risky`, or `Desperate`.
- Effect communicates the likely impact of success: `Limited`, `Standard`, or `Great`.

The player's chosen action, current scenario state, active modifiers, and current harms all contribute to the projection.

### 6.3. Stress

Stress is the party's primary short-term pressure valve.

Players can spend or take Stress to:

- Push Themselves for improved odds.
- Resist a consequence after a bad outcome.
- Absorb the cost of risky group coordination and authored scenario pressures.

Stress should feel like a renewable but dangerous resource. Overflow does not create a long-tail meta system in v1; it creates immediate expedition-level consequences.

### 6.4. Harm

Harm represents expedition injuries, curses, contamination, mental damage, and other scenario-specific afflictions.

- Lesser Harm imposes mild penalties.
- Moderate Harm imposes meaningful penalties.
- Severe Harm can shut down actions or remove a character from viable play.

Harm is scenario-facing as much as it is mechanical. A haunted-house scenario should harm differently from a pulp tomb or sci-fi freighter.

### 6.5. Clocks

Clocks are visual progress trackers for mounting danger, longer tasks, negotiations, and unstable scenario threats.

Examples:

- a collapsing tomb chamber
- a haunting escalating through the house
- a reactor approaching meltdown
- persuading a key NPC before they choose violence

Clocks should be one of the primary ways scenarios express rising tension.

### 6.6. Branching Scenario State

Scenarios branch through authored consequences that can:

- add or remove interactables
- unlock or close paths
- set flags and counters
- trigger events
- grant treasures or modifiers
- advance clocks
- end the run with a scenario-specific outcome

## 7. Game Structure

### 7.1. The Expedition Crawl Loop

1. The player chooses a scenario from a catalog of included, owned, and locked expeditions.
2. The game generates a party from that scenario's native archetype pool.
3. The player enters an authored expedition crawl built from scenario-defined nodes, maps, interactables, and scenario state.
4. The player navigates hazards, chooses characters and actions, resolves rolls, and manages stress, harm, clocks, treasures, and modifiers.
5. The scenario branches through authored consequences, changing the map, interactables, flags, counters, and event chains.
6. The run concludes in one of several likely endings based on the player's decisions, successes, failures, and accumulated scenario state.

### 7.2. Party Generation

Each run begins with a randomly generated party pulled from the selected scenario's native archetype pool.

This preserves freshness without requiring the entire product to lean on heavy procedural generation. Cross-scenario archetype remixing is explicitly outside the v1 scope.

### 7.3. Party Management

Party management is a major gameplay layer, but not a tactical-combat one.

Key questions should include:

- Which party member is best suited for this hazard?
- Is it worth risking the specialist here?
- Should the party split up for efficiency or stay together for safety?
- Is the group's current harm and stress burden sustainable?

### 7.4. Scenario Variation

Replayability comes mainly from:

- random party composition
- authored branching paths
- varying resource states and consequence chains
- multiple likely outcomes and endings

Optional scenario-local shuffling, such as obstacle pools, room pools, or encounter ordering, is a stretch goal rather than a foundational pillar.

## 8. Launch Content and Product Model

### 8.1. Launch Scenario Lineup

The launch version is planned around three scenarios:

- `Temple of Terror`: Included at no additional cost. A 1970s pulp expedition inspired by classic tomb-raiding adventure fiction and trap-filled dungeon design. This is the recommended first scenario and the clearest expression of the game's pulp-adventure side.
- `Shadow of a Doubt`: Included at no additional cost. A haunted-house expedition edging into occult and cosmic horror, centered on a cult that sees consciousness as evil and ghosts as trapped, tortured consciousness.
- `Charon's Bargain`: Available as a paid premium scenario at launch. A denser sci-fi horror expedition aboard a compromised freighter, with heavier authored state, consequence chains, and branching outcomes.

### 8.2. Monetization Model

Dice Delver is a free-to-download app with a scenario catalog.

- Some scenarios are included with the base app.
- Additional scenarios are sold individually as permanent unlocks through in-app purchase.
- Purchases are non-consumable and restorable.
- The long-term productization plan is to expand the anthology through ongoing scenario releases.

### 8.3. Scenario Pricing Tiers

Current planned pricing is based on authored scope and complexity.

- Standard scenarios: `$2.99`
- Premium scenarios: `$4.99`

The launch scenarios establish the intended shape of those tiers:

- `Temple of Terror` is representative of the Standard scenario tier.
- `Charon's Bargain` is representative of the Premium scenario tier.

`Shadow of a Doubt` is included at launch, but should still be scoped like a full peer scenario rather than a disposable tutorial.

## 9. User Interface and User Experience

### 9.1. The Card Metaphor

The primary interaction metaphor remains the card.

Each Interactable card should contain:

- a title
- descriptive text
- strong thematic presentation
- the available actions
- the relevant action types

Selecting an action should open the roll projection and resolution flow.

### 9.2. Main Screens

- Main Menu / Scenario Catalog: Start a new expedition, continue a run, view locked and owned scenarios, restore purchases, and access settings.
- Scenario Setup: Review a scenario's premise and assemble a randomly generated party from that scenario's native archetype pool.
- Node View: The primary gameplay screen, displaying the current location's interactables and immediate hazards.
- Party View: Shows the current party, their stress, harm, treasures, modifiers, and locations.
- Expedition Map View: Displays discovered nodes, current locations, and known routes.
- Dice Roll Projection View: Shows Position, Effect, modifiers, and the final roll commitment.
- Resolution / Decision View: Shows authored outcomes, resistance choices, and branching follow-up decisions.

### 9.3. UX Priorities

- Fast comprehension of risk before a roll.
- Strong thematic differentiation between scenarios.
- Clear visibility into party condition and scenario pressure.
- Minimal friction when resolving authored consequence chains.
- A premium-feeling scenario catalog that makes included, owned, and locked content legible.

## 10. Content Model

### 10.1. Scenario-Native Archetypes

Archetypes belong primarily to scenarios, not to a universal global roster.

Examples:

- `Temple of Terror`: Archaeologist, Linguist, Guide, and other pulp-expedition specialists.
- `Shadow of a Doubt`: Detective, Cultist, Ghost Hunter, and other occult-facing roles.
- `Charon's Bargain`: Pilot, Scavenger, Mercenary, Scientist, and other shipboard specialists.

### 10.2. Hazard Design

Hazards should be authored to create tension and irreversible momentum rather than combat puzzles.

Examples:

- traps
- unstable environments
- occult manifestations
- environmental contamination
- negotiation under pressure
- monsters as moving threats rather than tactical encounter boards

### 10.3. Scenario Outcomes

Scenarios should normally support multiple likely endings or run outcomes, even if the exact branches differ by scenario.

The goal is not just to win or lose, but to create expeditions with memorable paths, tradeoffs, and aftermaths.

## 11. Technical and Architecture Requirements

The architecture should prioritize authored scenario delivery over procgen-first replayability.

The runtime should cleanly support:

- scenario-specific manifests and content packs
- authored maps, interactables, events, clocks, and endings
- scenario-native archetype pools
- save/load of scenario state
- scenario validation and author tooling
- a scenario catalog layer separate from the scenario runtime
- entitlements for included, paid, owned, and locked scenarios
- in-app purchase integration and restore purchases
- future scenario expansion without invasive app rewrites

The scenario runtime and the commerce/catalog layer should remain separate concerns.

- Scenario content describes how a scenario plays.
- Catalog and store metadata describe how a scenario is surfaced, unlocked, ordered, and purchased.

## 12. Deferred or Not Core to v1

- Meta-progression systems.
- Cross-scenario archetype remixing.
- Bundle strategy beyond individual scenario purchases.
- Procgen-first dungeon generation as a core product pillar.
- Deep tactical combat as a primary gameplay focus.
- Any unlock system that competes with the clarity of individual scenario purchases.

## 13. Future Development

Future growth should come primarily through new authored scenarios that expand the anthology across settings and tones while remaining grounded in hazardous expeditions.

Likely directions include:

- occult mysteries
- survival horror
- frontier or desert disasters
- archaeological expeditions
- espionage-inflected disaster scenarios
- other self-contained scenario crawls with strong native archetype identities

Longer-term updates may explore remix systems, additional scenario-randomization layers, broader progression features, and alternate scenario-surface offers, but those should not distract from the core product goal of delivering a strong library of authored expeditions.
