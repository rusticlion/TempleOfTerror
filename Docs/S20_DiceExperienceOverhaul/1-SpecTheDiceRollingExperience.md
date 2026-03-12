## Task 1: Spec the Dice Rolling Experience Overhaul

**Goal:** Make the roll projection, throw, resistance, and results flow feel like one premium moment instead of several loosely connected UI states.

### Problems This Spec Solves

- The current roll flow is mechanically clear enough, but it still feels like forecast UI, dice tray, and consequence resolution belong to different systems.
- Resistance is especially awkward when more than one resistible consequence appears, because the player handles a hidden queue through repeated generic prompts.
- The tray is readable and the "tray inside the phone" metaphor is correct, but its materials and winner cue still feel more functional than atmospheric.
- The results view still behaves like a text log with decision buttons attached, rather than a paced dramatic reveal.

### Design Principles

- Keep the entire roll experience on one surface.
- Preserve current v1 rules unless a change is explicitly called out.
- Show consequences as concrete cards, not as a paragraph the player has to parse.
- Let the tray remain the emotional center of the interaction even after the initial action roll.
- Favor tactile, expedition-themed presentation over generic "game UI" effects.
- Preserve readability first; juice should support comprehension, not fight it.

### Desired Emotional Arc

1. The player reads the risk quickly.
2. The player commits with a sense of cost and intention.
3. The dice tray becomes the moment of truth.
4. The result lands with clarity and a little ritual.
5. Fallout is resolved on the same stage, without bouncing to a separate-feeling UI mode.

### Proposed Player Flow

#### 1. Forecast

The player sees:

- acting character
- action name and action rating
- final dice count
- Risk and Impact
- optional boosts and costs
- a short "why this changed" explanation

This screen should answer one question immediately: "What am I risking if I commit right now?"

#### 2. Commit

Selecting optional boosts should feel like loading the throw, not checking boxes in a form.

- Each boost should show both its upside and its cost in one line.
- The screen should show a compact "Loadout" summary directly above the roll button.
- Example: `3d6 -> 4d6`, `Risk stays Risky`, `Impact rises to Great`, `Cost: 2 Stress`.

The player should never need to compare two distant parts of the screen to understand what changed.

#### 3. Throw

The tray should remain visible and stable while the dice roll. The screen should not cut away from it or compete with it.

- The dice roll is the center of the interaction.
- Header copy and forecast chrome should visually recede during the throw.
- The tray should feel like an expedition instrument or relic surface, not a generic physics sandbox.

#### 4. Verdict

Once the dice settle, the UI should present a clean verdict before showing fallout.

- Outcome word: `Success`, `Partial`, `Failure`
- Highest result
- Critical marker when relevant
- Final Impact achieved

This should read like a single decisive beat, not the first line in a longer paragraph.

#### 5. Fallout

After the verdict lands, consequences should appear as structured fallout cards.

- Non-resistible consequences can resolve immediately into the aftermath log.
- Resistible consequences should appear as explicit cards with clear choices.
- If there are multiple resistible consequences, the player should see that queue up front.

#### 6. Aftermath

Resolved events should accumulate in a compact aftermath log below the active fallout area.

- Treasure gained
- Stress taken
- Harm applied
- Clocks ticked
- modifiers consumed
- follow-up narrative

This is the record of what happened, not the primary decision surface.

### Detailed UX Spec

#### Forecast Screen

The current forecast structure is close, but it needs a clearer hierarchy.

Required layout:

- Header: character, action, action rating
- Forecast band: dice count, Risk, Impact
- Delta summary: one short line summarizing the currently loaded version of the roll
- Optional boosts list
- "Why this changed" panel
- Dice tray
- Commit button

Behavior notes:

- Optional boosts should look like selectable tactical tags or kit cards, not checklist rows.
- The selected state should feel loaded and armed.
- The delta summary should update live and stay visually adjacent to the commit button.
- If the action is blocked, the blocked reason should replace the delta summary and commit affordance cleanly.

#### Dice Tray Art Direction

Keep the existing "tray inset into the screen" metaphor. Do not replace it with a floating abstract background or a full-screen VFX treatment.

The tray should feel like:

- worn expedition gear
- dark leather and stone
- brass or gilt edge wear
- faint ritual or survey markings
- slightly ceremonial, but still physical

Visual direction:

- Keep the top-down readability of the current tray.
- Increase material richness through surface wear, edge contrast, and more intentional lighting.
- Keep the center of the tray quieter than the edges so dice faces stay legible.
- Add subtle concentric scoring, engraved guide marks, or relic-style inlay to make the tray feel authored rather than plain.
- Avoid busy texture, heavy symbols, or bright overlays beneath the dice.

Recommended tray treatment:

- frame: dark oiled leather or aged wood with warmer highlights
- floor: basalt / felt / dusted stone hybrid texture with faint engraved rings
- lip/walls: worn bronze or darkened brass accents
- lighting: warm key light, low cool fill, stronger contact shadow under dice

Future-facing note:

- The base tray should work across scenarios.
- Scenario-native variants can later swap accent color or engraved motif without changing layout or interaction.

#### Result Emphasis In The Tray

The current winner cue is readable but too generic. Replace the continuous pulse with a short ritualized "judgment" sequence.

Winner cue sequence:

1. Dice settle and hold for a brief beat.
2. Losing dice dim and cool slightly.
3. The winning die gets a short lift in light and scale, not a looping pulse.
4. A thin ring or etched flare appears beneath the winning die on the tray floor.
5. A short light sweep passes across the winning face, then fades.

Guidelines:

- The winner cue should last roughly 0.6 to 0.9 seconds total.
- Avoid infinite pulsing or "mobile game reward chest" behavior.
- The winning die should feel chosen, not celebrated cartoonishly.
- The cue should be more like omen, judgment, or revelation than arcade feedback.

Critical cue:

- If multiple sixes create a critical, highlight each contributing die.
- Use paired rings or a brief linking shimmer between the winning dice.
- The critical treatment should feel clearly distinct from a normal full success.

Outcome tint guidance:

- Success: warm parchment-gold
- Partial: brass / amber
- Failure: ember-red
- Resistance attribute accents should layer on top of this only during resistance mode

#### Resistance And Fallout Flow

This is the main redesign.

Replace the current generic resistance prompt with a fallout stack that lives inside the same roll screen.

Each active fallout card should show:

- a short type label such as `Lesser Harm`, `+1 Stress`, `Clock +2`
- the authored flavor line if present
- a plain-language mechanical summary if flavor text is missing
- the resistance attribute, if resistible
- the post-resist preview, such as `Resist: reduce to Lesser Harm` or `Resist: reduce clock to +1`

Single-consequence case:

- Show one large fallout card under the verdict.
- The player chooses `Accept` or `Resist`.
- If they resist, the tray immediately becomes a resistance tray and the same screen continues.

Multiple-consequence case:

- Show the current active fallout card in full.
- Show the remaining fallout as a compact queue below it.
- Include a progress label such as `Fallout 1 of 3`.
- Resolving one card should advance to the next without collapsing the whole view or resetting the scene.

Important rules note:

- This spec preserves the current v1 rule that each resistible consequence is handled individually.
- This is a presentation and flow overhaul, not a resistance rules rewrite.
- Bundled resistance for multiple authored consequences is a possible later experiment, but it is out of scope for this pass.

Resistance roll presentation:

- Do not resolve resistance invisibly.
- Reuse the same tray.
- Tint the tray accent by resistance attribute.
- Show the resistance dice pool and stress rule directly above the tray.
- After the resistance roll, animate the fallout card into its reduced or avoided state before moving on.

Attribute mood guidance:

- Insight: cold lantern / verdigris tint
- Prowess: rust / blood-warm bronze tint
- Resolve: ember-gold tint

#### Results Display

The post-roll screen should be broken into three layers:

- Verdict
- Active Fallout
- Aftermath

Verdict is large and brief.

Active Fallout is interactive and card-based.

Aftermath is a vertically stacked log of resolved rows.

Aftermath row examples:

- `Gained Treasure: Warding Charm`
- `Temple Collapse +1`
- `Suffered Lesser Harm: Twisted Ankle`
- `Used up Silk Rope`
- `The consequence was avoided`

Presentation rules:

- Do not dump all consequence text into a single scroll area first.
- Do not make the player read the full aftermath log to discover what still needs a decision.
- The `Done` button should remain disabled until there is no active fallout or follow-up choice.

#### Copy And Tone

Use language that sounds like expedition pressure, not tutorial UI.

Preferred tone:

- `Fallout`
- `Resist with Prowess`
- `This will land unless resisted`
- `Resist to reduce this to Lesser Harm`
- `Avoided`
- `Reduced`

Avoid copy that feels abstract or placeholder-like:

- `A consequence is about to land.`
- `Awaiting your decision.`

If authored flavor text is missing, generate a mechanical fallback that is still concrete:

- `Temple Collapse advances by 2.`
- `You would take 1 Stress.`
- `You would suffer Moderate Harm: Head Trauma.`

### Component And Data Implications

Primary files likely affected:

- `CardGame/DiceRollView.swift`
- `CardGame/SceneKitDiceView.swift`
- `CardGame/DieNode.swift`
- `CardGame/ConsequenceExecutor.swift`
- `CardGame/Models.swift`
- `CardGame/GameViewModel.swift`
- `CardGame/ContentView.swift`
- `CardGame/InRunUXSupport.swift`
- `CardGameUITests/CardGameUITests.swift`
- `CardGameTests/CardGameTests.swift`

Data/model implications:

- `PendingResistanceState` is not rich enough for the target UI on its own.
- The pending resolution system should expose structured fallout items rather than only a joined description string.
- The resolution model should track:
  - active fallout item
  - remaining fallout queue
  - resolved aftermath rows
  - active resistance roll presentation state

Presentation implications:

- `DiceRollView` should own the full roll-to-resolution sequence.
- `PendingResolutionView` should either become a visual wrapper around the same components or be reduced to a resume/fallback shell for re-entering an unresolved roll.
- The player should not feel like they moved from "dice mode" into "generic modal mode" after the throw.

### Suggested Implementation Slices

#### Slice 1: Restructure The Presentation Without Changing Rules

- Split the current results area into Verdict, Fallout, and Aftermath sections.
- Replace the single narrative block as the primary surface.
- Keep current underlying consequence rules intact.

#### Slice 2: Introduce A Structured Fallout Queue

- Surface multiple resistible consequences as a visible queue.
- Add generated fallback summaries for resistible items with missing authored text.
- Keep accept/resist decisions inside the same screen.

#### Slice 3: Make Resistance A Real Tray Moment

- Reuse the tray for resistance rolls.
- Add attribute tinting, dice-pool copy, and resolved-card transitions.

#### Slice 4: Polish The Tray Itself

- Refine tray materials and lighting.
- Replace the generic pulse with the judgment sequence.
- Improve critical highlighting.

#### Slice 5: Tune And Test

- UI tests for single and multi-fallout resolution
- tests for resumed pending resolution state
- tests for resistance copy when authored description is missing
- tests for critical and winner highlighting behavior where practical

### Asset Callouts

Required for this spec:

- Refine the existing tray-floor texture so the tray feels intentionally part of the world.

Not required for the first pass:

- A new winner-cue art asset
- scenario-specific tray skins
- new audio beyond tuning the already planned roll / land / pop layering

The winner cue should be implemented code-first using lighting, opacity, scale, and a tray-floor ring effect. If that still feels too plain, add a scenario-native sigil decal later.

### Definition Of Done

- The full dice interaction reads as one continuous experience.
- A single resistible consequence is understandable at a glance.
- Multiple resistible consequences can be resolved on the same screen without generic repeated prompts.
- Resistance rolls visibly use the tray.
- The winning die cue feels thematic rather than like a generic pulse.
- The tray looks materially aligned with the rest of the parchment / leather / gold presentation.
- The aftermath of a roll is readable as discrete events rather than a single text block.
