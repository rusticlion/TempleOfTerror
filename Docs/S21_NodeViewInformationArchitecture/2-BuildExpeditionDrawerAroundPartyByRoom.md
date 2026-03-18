Task 2: Build the Expedition Drawer Around a Party-by-Room View

**Goal:** Replace the current generic status sheet with an expedition drawer that helps the player understand party organization, split status, active clocks, and explorer readiness at a glance, without forcing that information onto the main node screen.

## Why This Pass Exists

The current `StatusSheetView` usefully combines clocks and party state, but it is still mostly a vertical stack of separate panels. It does not fully solve the question that matters most when the party is split:

- who is where?
- who is alone?
- who is under pressure?
- who should act next?

This pass should make the drawer feel like an expedition-control surface rather than a catch-all overflow sheet.

## Scope

In scope:

- `CardGame/StatusSheetView.swift`
- party grouping by current room
- compact explorer rows
- active clocks section inside the drawer
- drill-down into full `CharacterSheetView`

Out of scope:

- redesigning the map screen
- changing map logic
- changing party movement rules
- changing harm, treasure, or stress mechanics

## Core Decision

The drawer should organize the party by room first, then by explorer.

This is the key distinction from the current party sheet. When the party is split, the relevant question is not only "what does each explorer have?" It is "how is the expedition distributed across the map right now?"

## Proposed Layout

```text
╭─────────────────────────────────────────────╮
│ Expedition                            Close │
│ Split: 2 rooms        2 active clocks       │
├─────────────────────────────────────────────┤
│ Party By Room                               │
│                                             │
│ River Landing (2)                    Threat │
│ ┌ Nadia Al-Hassan           Stress 3 / 9 ┐ │
│ │ Guide                    [Fresh][Active]│ │
│ │ Study 1 • Survey 3 • Prowl 2 • Tinker 1│ │
│ └─────────────────────────────────────────┘ │
│ ┌ Omar Voss                 Stress 1 / 9 ┐ │
│ │ Archaeologist            [Lesser][Ready]│ │
│ │ Study 3 • Survey 2 • Wreck 1           │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Sun Gate (1)                         Alone  │
│ ┌ Evelyn Price             Stress 6 / 9  ┐ │
│ │ Mystic                 [Moderate][Engaged]│
│ │ Attune 3 • Command 2 • Survey 1        │ │
│ └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────┤
│ Active Pressure                             │
│ Collapse Chamber                      2 / 4 │
│ Boatman Panic                          1 / 4│
├─────────────────────────────────────────────┤
│ Tap a row to switch acting explorer.        │
│ Open details for full harm / treasure view. │
╰─────────────────────────────────────────────╯
```

## Top Summary Line

Required contents:

- party organization state:
  - `Together`
  - `Scout`
  - `Split: 2 rooms`
- count of active clocks, if any

Rules:

- This summary should remain compact.
- It should describe the expedition as a whole, not repeat the selected room.
- If there are no active clocks, the right side may be omitted or replaced with another short expedition-level summary.

## Party by Room

This is the primary section in the drawer.

Behavior:

- Group explorers by their current room.
- Sort room groups consistently, ideally with the selected explorer's room first, then alphabetically or by discovery / map order.
- Show room occupancy count in the section header.
- Room headers may include one compact room-state chip, such as:
  - `Threat`
  - `Alone`
  - `Current`

Rationale:

- Room grouping makes split-party consequences legible immediately.
- It avoids repeating room names in the main node view where they are already implied by the selected explorer.

## Explorer Row Anatomy

Each explorer row should be compact but comparison-friendly.

Required contents:

- explorer name
- stress as `x / 9`
- archetype / class
- coarse harm-state chip:
  - `Fresh`
  - `Lesser`
  - `Moderate`
  - `Severe`
  - `Defeated`
- one or two secondary state chips where relevant:
  - `Active`
  - `Ready`
  - `Engaged`
  - `Alone`
- every action with at least 1 pip

Important rule:

- Show **every** action rating with at least 1 pip.
- Do **not** truncate to only the top two actions.

Rationale:

- Generalist explorers derive much of their identity from broad 1-pip coverage.
- Reducing the row to only the strongest two actions would misrepresent those explorers and make party-comparison decisions worse.

Suggested action formatting:

- wrapped inline list:
  - `Study 1 • Survey 3 • Prowl 2 • Tinker 1`
- use a second line wrap rather than horizontal scrolling

Disallowed contents:

- full stress pip track
- treasure inventory
- full harm slot breakdown
- full tag cloud
- detailed modifier list

Those belong in the full character sheet.

## Row Interaction Model

Recommended behavior:

- tap the main body of a row:
  - make that explorer the active selected explorer
  - dismiss the drawer
- optional trailing affordance such as chevron or `Details`:
  - open `CharacterSheetView` for deeper inspection without changing the main layout model

If only one tap target is practical in the first pass:

- tapping the row should select the explorer and close the drawer
- the full character sheet can remain reachable from the node-screen active explorer HUD or a later refinement

## Active Pressure Section

This section should contain the full list of active clocks.

Rules:

- All active clocks with progress > 0 should appear here.
- The compact node-view pressure row only shows the most urgent subset.
- The drawer is where the player can review the broader pressure landscape.

This lets the main node view stay focused without losing expedition-level awareness.

## Relationship to Existing Surfaces

- `StatusSheetView` evolves into this expedition drawer.
- `CharacterSheetView` remains the detailed per-explorer drill-down.
- `MapView` remains a separate spatial screen rather than being folded into this drawer.

This keeps responsibilities clear:

- node view: immediate scene choices
- expedition drawer: party organization and current pressure
- character sheet: deep per-explorer details
- map: spatial understanding

## Implementation Notes

Primary file targets:

- `CardGame/StatusSheetView.swift`
- `CardGame/CharacterSheetView.swift`
- `CardGame/ContentView.swift`

Helpful support work may also touch:

- `CardGame/GameViewModel.swift`
- `CardGame/InRunUXSupport.swift`

Suggested implementation order:

1. Replace the current simple clocks-plus-party stack in `StatusSheetView`.
2. Add room-grouping helpers based on `characterLocations`.
3. Build compact explorer rows with stress, harm chips, and wrapped non-zero action lists.
4. Surface room-level chips such as `Threat` or `Alone` where useful.
5. Wire row tap behavior to select the acting explorer from the drawer.
6. Keep the existing full character sheet as the deeper drill-down.

## Acceptance Criteria

- The drawer makes split-party state understandable at a glance.
- Every explorer row shows all actions with at least 1 pip.
- Players can compare party members quickly without opening every full character sheet.
- Active clocks remain easy to review from the drawer.
- The node screen no longer needs a permanent movement-status panel or a full clocks panel because this drawer now carries that responsibility cleanly.

## Deferred Follow-Ups

- richer room-header affordances tied to scenario theme
- map shortcut from inside the expedition drawer
- drag or segmented navigation between `Party`, `Pressure`, and `Map` if the drawer grows too long
- stronger visual emphasis for isolated or endangered explorers
