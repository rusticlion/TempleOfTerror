Ticket 1: Ambient World
Description: Make the dungeon feel like a real place by giving each room a subtle, looping ambient soundscape. We'll also replace the default view transition with a more thematic "sliding stone door" effect when moving between nodes.

Implementation Plan:

Ambient Audio:
Create a simple AudioManager singleton class to handle playback of background audio. It will need functions like play(sound: String, loop: Bool) and stop().
In GameViewModel.swift, when calling move(to:), also call AudioManager.shared.play(sound: "ambient_\(newNode.soundProfile).wav", loop: true).
We'll add a new property to our MapNode model, var soundProfile: String, which we can set in our content files (e.g., "cave_drips", "chasm_wind").
Thematic Transition:
Instead of the default .transition(.opacity) on the content VStack in ContentView, we will use a .matchedGeometryEffect.
We will create a "door" view that slides across the screen. We can achieve this with a ZStack in ContentView. When a move is initiated, we'll show a black rectangle (our door) that animates its width from 0 to the screen's full width, and then back to 0, revealing the new content underneath.
Asset Callouts:

Audio (Ambient Loops):
ambient_cave_drips.wav: A quiet, sparse loop of echoing water drips.
ambient_chasm_wind.wav: A low, windy rumble with an occasional pebble-skittering sound.
ambient_silent_tomb.wav: Mostly silence, with a very faint, deep hum.
Audio (Transitions):
sfx_stone_door_slide.wav: A heavy, scraping sound of stone on stone to play during the screen transition.
Visual:
texture_stone_door.png: A full-screen tiling image of dithered, retro-style stone. This will be used for the transition view instead of a plain black color.
Canvas Size: 256x256 pixels. (A square, power-of-two texture is efficient for tiling.)