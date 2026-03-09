import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private var missingSounds = Set<String>()

    private var isPlaybackEnabled: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] == nil
            && environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
    }

    func play(sound: String, loop: Bool = false) {
        guard isPlaybackEnabled else { return }

        guard let url = Bundle.main.url(forResource: sound, withExtension: nil) else {
            reportMissingSound(named: sound)
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

    private func reportMissingSound(named sound: String) {
        guard missingSounds.insert(sound).inserted else { return }
        print("Missing sound: \(sound)")
    }
}
