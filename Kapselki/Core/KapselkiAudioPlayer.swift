import AVFoundation
import Foundation

final class KapselkiAudioPlayer: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]

    func play(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }

        do {
            let player = try players[name] ?? AVAudioPlayer(contentsOf: url)
            player.currentTime = 0
            player.volume = name == "finish_applause" ? 0.55 : 0.72
            player.prepareToPlay()
            player.play()
            players[name] = player
        } catch {
            // Audio is optional; gameplay should stay responsive even if a file is missing.
        }
    }
}
