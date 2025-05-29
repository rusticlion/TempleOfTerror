Ticket 3: Thematic Status Visualization
Description: Replace the default ProgressView bars for Stress and Harm with custom-drawn, thematic icons that better reflect the game's aesthetic and provide clearer at-a-glance information.

Implementation Plan:

Stress Pips: In PartyStatusView.swift, remove the ProgressView for Stress. Replace it with an HStack that iterates from 1 to 9. For each number, draw a "pip" icon. If the character's stress is greater than or equal to the pip's number, the pip is "lit"; otherwise, it's "unlit."
Harm Icons: Remove the three harm ProgressViews. Replace them with a single HStack.
Draw two "Lesser" icons. For each filled lesser harm slot, draw the "cracked" version of the icon.
Draw two "Moderate" icons. For each filled moderate harm slot, draw its cracked version.
Draw one "Severe" icon. If the severe slot is filled, draw its cracked version.
Asset Callouts:

Visual (Stress):
icon_stress_pip_unlit.png: A small, dithered gray or dark purple circle or rune.
Canvas Size: 48x48 pixels.
icon_stress_pip_lit.png: The same icon, but with a bright, ominous purple or red dithered glow.
Canvas Size: 48x48 pixels.
Visual (Harm): We'll use a "cracked skull" motif.
icon_harm_lesser_empty.png: A small, simple, dithered skull icon.
Canvas Size: 64x64 pixels.
icon_harm_lesser_full.png: The same skull with a single, dithered crack on it.
Canvas Size: 64x64 pixels.
icon_harm_moderate_empty.png: A slightly more detailed/angular skull icon.
Canvas Size: 64x64 pixels.
icon_harm_moderate_full.png: The moderate skull with more severe, branching cracks.
Canvas Size: 64x64 pixels.
icon_harm_severe_empty.png: A stylized, grim-looking skull.
Canvas Size: 64x64 pixels.
icon_harm_severe_full.png: The severe skull, heavily cracked and possibly with a red dithered glow in one eye socket.
Canvas Size: 64x64 pixels.