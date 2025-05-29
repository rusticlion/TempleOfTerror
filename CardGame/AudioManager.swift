import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?

    func play(sound: String, loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: nil) else {
            print("Missing sound: \(sound)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            if loop {
                player?.numberOfLoops = -1
            }
            player?.play()
        } catch {
            print("Failed to play \(sound): \(error)")
        }
    }

    func stop() {
        player?.stop()
    }
}
