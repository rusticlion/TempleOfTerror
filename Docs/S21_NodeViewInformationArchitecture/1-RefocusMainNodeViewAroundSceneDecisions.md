Task 1: Refocus the Main Node View Around Scene Decisions

**Goal:** Reduce main-screen overload by making the node view primarily about the current room, the acting explorer, and the next decision, while moving broader expedition management into secondary surfaces.

## Why This Pass Exists

The current node screen is mechanically rich and readable, but it still mixes too many layers of play into one scroll stack:

- room context
- current pressure
- active explorer summary
- expedition organization
- party movement explanation
- interactables and paths

The result is that the player often reads several full-width informational panels before reaching the actual choices in the room.

This pass should make the node view feel more like a scene and less like a dashboard.

## Core Decision

The node view should answer four questions in this order:

1. Where am I?
2. What is urgent here?
3. Who is acting, and what can they do?
4. What choices are available right now?

Anything that does not directly support those questions should move to a secondary surface.

## Scope

In scope:

- `CardGame/ContentView.swift`
- compact room-pressure presentation
- active explorer tactical HUD
- streamlined bottom command dock
- removal of redundant permanent status panels from the main play surface

Out of scope:

- redesigning the dice roll screen
- redesigning the full character sheet
- redesigning the map screen
- changing movement or threat rules
- changing clocks or consequence rules

## Design Principles

- The node view is a scene screen, not a full expedition dashboard.
- Stress and action ratings for the acting explorer are decision-critical and must remain visible.
- Treasures, detailed harm slots, and global party organization are important but secondary.
- Split / together state is primarily a party-control state and should live in the bottom dock, not in multiple top-of-screen banners.
- If a player must scroll past multiple informational panels before seeing the first interactable, the screen is still overloaded.

## Proposed Layout

```text
┌─────────────────────────────────────────────┐
│ River Landing                        [?][≡]│
│ [Threat Here] [Collapse 2/4]                │
├─────────────────────────────────────────────┤
│ NADIA AL-HASSAN, Guide                      │
│ Stress: ● ● ● ○ ○ ○ ○ ○ ○                   │
│ Study 1 • Survey 3 • Prowl 2 • Tinker 1     │
│ Immediate: Prowl -1d • Tinker blocked       │
├─────────────────────────────────────────────┤
│ ┌ Abandoned Field Journal ────────────────┐ │
│ │ Handwritten route notes and sketches.   │ │
│ │ Review the sketches                     │ │
│ │ Survey 3          Risky • Standard      │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Paths                                       │
│ [Toward the Sun Gate]                       │
├─────────────────────────────────────────────┤
│ [Arch] [Guide*] [Mystic]                    │
│ [Together / Scout / Split: 2 rooms]        │
│                              [Map] [Party]  │
└─────────────────────────────────────────────┘
```

## Layout Regions

### 1. Header

Required contents:

- current node name
- quick reference affordance
- expedition drawer affordance

Rules:

- The header should represent the room, not the whole expedition.
- Do not repeat split-state or acting-character location here.
- Keep the header compact enough that the first interactable can appear above the fold on smaller phones.

### 2. Compact Pressure Row

This replaces the current stack of large status cards at the top of the node view.

Allowed contents:

- `Threat Here`
- `Movement Blocked`
- the single most important visible clock
- one additional compact pressure chip if needed

Disallowed contents:

- split / together state
- active explorer location
- broad movement instructions
- long instructional copy

Behavior:

- If no pressure is active, the row may collapse to a minimal spacer or disappear entirely.
- If the current room contains an active threat, the pressure row should clearly communicate that movement is blocked.
- If clocks are active, the row should show only the most urgent one plus an optional overflow indicator such as `+1 more`.

### 3. Active Explorer Tactical HUD

This replaces the current selected-character summary strip with a more decision-oriented HUD.

Required contents:

- explorer name
- archetype / class
- stress track
- every action rating with at least 1 pip
- immediate penalties or bans relevant to currently visible room actions

Disallowed contents:

- treasure inventory
- detailed harm slot breakdown
- full state-tag listing
- acting explorer location text

Presentation notes:

- Non-zero action ratings should be shown in a compact wrapped format such as:
  - `Study 1 • Survey 3 • Prowl 2 • Tinker 1`
- If there are no immediate penalties or bans affecting visible room actions, omit the warning line entirely.
- Harm should be represented here only coarsely if needed, for example through a small chip or tint; the full harm details belong elsewhere.

Rationale:

- Stress and action ratings are core inputs for deciding who should act and which action is sensible.
- Hiding them behind the party drawer would make the screen cleaner but materially worse to play.

### 4. Interactable Stack

The interactables remain the dominant content on the page.

Rules:

- Interactables should visually dominate the node view.
- Action rows should continue to show action type, current risk, and current impact.
- Action rows should also show the acting explorer's rating for that action inline when practical.
- Keep the current card metaphor.

Suggested action-row line format:

- `Survey 3`
- `Risky • Standard`
- optional compact cues such as `Auto`, `Bonus ready`, or `Blocked`

### 5. Paths Section

The paths section belongs below the interactables and should remain part of the room scene.

Rules:

- If movement is allowed, show paths normally.
- If movement is blocked by a threat, replace the normal path list with a compact blocked-state stub.
- Do not keep a separate full-width explanatory movement panel above the paths.

### 6. Bottom Command Dock

The bottom dock becomes the home for party organization and utility navigation.

Required contents:

- character selector rail
- one movement-mode control
- `Map` button
- `Party` button

Rules:

- Split / together state lives here, not in the pressure row and not in the active explorer HUD.
- The movement-mode control label should summarize state directly:
  - `Together`
  - `Scout`
  - `Split: 2 rooms`
- Remove the current persistent `PartyMovementStatusView` block from the main scroll surface.

## Existing UI Elements to Remove from the Main Scroll Surface

These should no longer appear as full-width permanent sections above the interactables:

- `CondensedClockPanel`
- `ContextualInfoBanner`
- inline guidance cards shown by default in the main scroll flow
- `PartyMovementStatusView`
- the expandable inline `CharacterSheetView`

These features are not being deleted from the game; they are being moved or compressed.

## Guidance / Teaching Strategy

The current hint system is useful, but full-width hint cards should not become permanent layout peers to interactables.

Recommended approach:

- keep onboarding hints
- prefer temporary overlays, small affordances, or one-time inserted hints
- avoid stacking multiple persistent instructional cards above room content

## Implementation Notes

Primary file targets:

- `CardGame/ContentView.swift`
- `CardGame/InRunUXSupport.swift`
- `CardGame/InteractableCardView.swift`
- `CardGame/CharacterSelectorView.swift`

Suggested implementation order:

1. Remove the permanent top-of-scroll clocks and contextual panels.
2. Introduce a compact pressure row model derived from current threat and active-clock state.
3. Replace the current selected-character strip with an active explorer tactical HUD.
4. Remove the inline expandable character sheet from the node screen.
5. Collapse party-organization state into the bottom dock.
6. Update action rows to include acting-character rating inline where it improves readability.

## Acceptance Criteria

- The first interactable is visible substantially sooner on a typical iPhone screen.
- The node view still shows the acting explorer's stress and non-zero action ratings without opening another surface.
- Split / together state appears in only one persistent place on the node screen: the bottom dock.
- The top of the node view no longer contains a stack of multiple full-width informational panels competing with room content.
- The node view reads primarily as a room scene with decisions, not as a general expedition dashboard.

## Deferred Follow-Ups

- scenario-specific HUD ornamentation
- animation polish for the command dock
- richer visual distinction between room pressure types
- deeper action-row comparison affordances for edge cases with many available actions
