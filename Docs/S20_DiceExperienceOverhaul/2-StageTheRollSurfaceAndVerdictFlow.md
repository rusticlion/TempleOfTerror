Task 2: Stage the Roll Surface and Verdict Flow

**Goal:** Make the next dice pass feel authored and premium by anchoring the tray as the emotional center of the screen, reducing scroll friction before commitment, giving resistance its own payoff beat, and making criticals and aftermath read with stronger hierarchy.

## Why This Pass Exists

The current prototype already has the right systems:

- one-screen continuity
- optional boosts and loadout summary
- a reusable tray for both action and resistance rolls
- active fallout cards and a queued resistance preview

What still feels off is the staging:

- the tray, loadout, and primary CTA can separate from each other on smaller screens
- resistance resolves correctly, but it does not land with a clear post-roll verdict
- criticals are mostly textual even though the tray should be their visual payoff
- the aftermath block is too prominent while a fallout choice is still active

This pass is about presentation, pacing, and hierarchy. It does **not** change core roll or resistance rules.

## Scope

In scope:

- `DiceRollView.swift` layout and sequencing refinements
- `ResolutionDecisionCard` pacing and resistance-state presentation
- `SceneKitDiceView.swift` and `DieNode.swift` winner / critical treatment upgrades
- compact aftermath presentation rules
- targeted UI test updates for the new roll-stage behavior

Out of scope:

- changing FitD roll math or resistance rules
- bundling multiple resistible consequences into one roll
- scenario-native tray skins
- new PNG or audio asset requirements

## Experience Goals

The revised flow should create this arc:

1. The player reads risk quickly.
2. The player loads the throw without hunting across the screen.
3. The tray and CTA stay together at the moment of commitment.
4. The verdict lands cleanly.
5. Resistance gets its own brief ritual on the same stage.
6. Aftermath becomes a record, not a competitor for attention.

## Proposed Changes

### 1. Pin the Roll Stage

The tray, loadout summary, and primary action button should live in a persistent bottom stage rather than inside the same long scroller as the forecast content.

Behavior:

- Keep forecast, optional boosts, and "why this changed" content in the scrollable region.
- Move the tray, loadout summary, resistance instructions, and the primary CTA into a bottom stage using a pinned treatment such as `safeAreaInset(edge: .bottom)`.
- On compact screens, the forecast can scroll behind the fixed stage.
- During the throw, the upper forecast chrome should subtly recede so the tray feels dominant.

Design notes:

- The loadout summary must remain visually adjacent to the CTA.
- If the action is blocked, the stage still appears, but the summary becomes a blocked-state message and the CTA becomes a disabled banned action affordance.
- The player should never need to scroll to find the commit button after choosing boosts.

Primary files:

- `CardGame/DiceRollView.swift`

### 2. Add a Resistance Verdict Beat

Resistance currently has a readable setup state, but the payoff disappears too quickly after the roll resolves. The tray should stay in resistance mode long enough to show what the player bought with Stress.

Behavior:

- After a resistance roll settles, keep the resistance tint and tray state active for a short verdict phase.
- Show a compact resistance verdict panel directly above the tray.
- The panel should include:
  - attribute used
  - highest die
  - Stress cost
  - outcome summary such as `Consequence Avoided` or `Reduced to Lesser Harm`
- After that panel appears, animate the active fallout card into its reduced or avoided state.
- Only then should the queue advance to the next fallout item.

Implementation notes:

- Add a lightweight UI state in `DiceRollView` for the most recent resolved resistance roll.
- Extend `ConsequenceExecutor.ResistanceRollOutcome` with a player-facing resolution summary, or add a parallel lightweight result model returned from the resistance pipeline.
- Preserve the existing `Take It` path and queue behavior.

Primary files:

- `CardGame/DiceRollView.swift`
- `CardGame/ConsequenceExecutor.swift`
- `CardGame/GameViewModel.swift`

### 3. Give Criticals a Distinct Tray Treatment

Criticals should look materially different from a normal success. Right now only one die is highlighted, which flattens the moment.

Behavior:

- Support highlighting multiple winning dice when a critical occurs.
- Replace the current single-die emphasis with a short judgment sequence:
  - settle beat
  - losing dice dim
  - winning dice lift in light and scale
  - etched ring markers appear beneath each winning die
  - a brief linking shimmer or paired cue distinguishes a critical from a normal success
- Avoid infinite pulsing.

Implementation notes:

- Replace the single `highlightIndex` flow with support for multiple highlighted dice.
- Update the tray marker logic to render multiple markers when needed.
- Keep the timing short and ceremonial rather than celebratory.

Primary files:

- `CardGame/DiceRollView.swift`
- `CardGame/SceneKitDiceView.swift`
- `CardGame/DieNode.swift`

### 4. Demote Aftermath Until It Has Substance

The aftermath block is useful, but it should not visually rival the active fallout card while the player is still making decisions.

Behavior:

- If no aftermath entries exist yet, replace the large empty card with a compact helper line.
- While `pendingResolution.isAwaitingDecision` is true, the active fallout card should remain visually dominant.
- Once real aftermath entries exist, show a compact stacked log.
- Keep the log readable, but cap its initial visual footprint.

Design notes:

- Empty-state copy should reassure the player that resolved events will collect here.
- The log should feel archival, not urgent.
- Do not remove the aftermath record; just reduce its weight until it earns attention.

Primary files:

- `CardGame/DiceRollView.swift`

## Implementation Order

### Phase 1: Layout Refactor

- Split `DiceRollView` into a scrollable content region and a pinned bottom stage.
- Keep accessibility identifiers stable where possible.
- Update UI tests that currently rely on swiping to reach the roll button.

### Phase 2: Resistance Verdict State

- Introduce a transient resistance verdict UI state in `DiceRollView`.
- Extend the resistance result returned from the engine with enough information to explain the outcome in one short line.
- Sequence the verdict before advancing the fallout queue.

### Phase 3: Critical / Winner Cue Upgrade

- Refactor tray highlighting to support one or more winning dice.
- Add multi-marker support in SceneKit.
- Tune timing so normal wins and criticals feel related but distinct.

### Phase 4: Aftermath Compression

- Replace the empty aftermath card with a compact placeholder.
- Reduce the default height and visual weight of the aftermath block while decisions are pending.

### Phase 5: Polish and Validation

- Verify the pinned stage on smaller iPhone layouts.
- Verify resistance queue handling across multiple consecutive resistible consequences.
- Verify criticals, ordinary successes, partials, and failures all produce coherent tray emphasis.

## Suggested Data / State Additions

These are small additions intended to support the revised pacing cleanly:

- `DiceRollView`
  - replace single highlighted-die state with plural winner state
  - add `recentResistanceVerdict` state with attribute, dice, Stress cost, and summary text
  - add a short-lived mode for "showing resistance result before queue advances"
- `ConsequenceExecutor.ResistanceRollOutcome`
  - add `resolutionSummary`
  - optionally add a simple enum such as `avoided` / `reduced`

No new persistence requirements are needed for this pass; these are presentational runtime states.

## Test Plan

Add or update UI coverage for:

- roll button remains reachable without manual scrolling after boosts are selected
- resistance verdict appears after a resistance roll before the next fallout card becomes active
- critical rolls visually differentiate from ordinary success states
- empty aftermath no longer renders as a large decision-competing card

Add targeted logic coverage if needed for:

- multi-die winner index selection for criticals
- resistance summary generation

## Definition of Done

- The tray, loadout summary, and primary roll CTA stay visually grouped throughout the pre-roll flow.
- The player can always understand the currently loaded version of the throw without scanning distant parts of the screen.
- Resistance rolls produce a distinct post-roll verdict beat on the same screen before the fallout queue advances.
- Criticals visibly highlight all contributing dice, not just one die plus text.
- The aftermath layer no longer dominates the screen when nothing has resolved yet.
- Existing rules behavior remains unchanged.

## Deferred Follow-Ups

These are valuable, but should not block this pass:

- richer tray material pass with more relic-like authored detail
- more precise dice impact sound timing
- scenario-native tray variants
- stronger motion design for the forecast chrome during the throw
