import AVFoundation
import Foundation

final class KapselkiAudioPlayer: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]
    private var loopPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var activeSlideLoopName: String?
    private var hasConfiguredSession = false

    func startMusic() {
        guard let url = Bundle.main.url(forResource: "playground_theme_loop", withExtension: "wav") else {
            return
        }

        do {
            configureSessionIfNeeded()
            if musicPlayer?.url == url, musicPlayer?.isPlaying == true {
                return
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0
            player.prepareToPlay()
            player.play()
            player.setVolume(0.12, fadeDuration: 0.80)
            musicPlayer = player
        } catch {
            // Audio is optional; gameplay should stay responsive even if a file is missing.
        }
    }

    func stopAll() {
        stopSlideLoop()
        musicPlayer?.setVolume(0, fadeDuration: 0.20)
        musicPlayer?.stop()
        musicPlayer = nil
        players.values.forEach { $0.stop() }
        players.removeAll()
    }

    func playFlick() {
        play("cap_flick", volume: 0.72, rate: Float.random(in: 0.96...1.08))
    }

    func playHit() {
        play("cap_hit", volume: 0.68, rate: Float.random(in: 0.92...1.10))
    }

    func playPenalty() {
        play("penalty_squeak", volume: 0.74, rate: Float.random(in: 0.96...1.04))
    }

    func playPowerUp() {
        play("powerup_chime", volume: 0.78, rate: Float.random(in: 0.98...1.06))
    }

    func playFinish() {
        play("finish_fanfare", volume: 0.72)
        play("finish_applause", volume: 0.46)
    }

    func startSlideLoop(named name: String, volume: Float) {
        guard activeSlideLoopName != name else {
            return
        }

        stopSlideLoop(fadeDuration: 0.10)
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }

        do {
            configureSessionIfNeeded()
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0
            player.prepareToPlay()
            player.play()
            player.setVolume(volume, fadeDuration: 0.18)
            loopPlayers[name] = player
            activeSlideLoopName = name
        } catch {
            // Audio is optional; gameplay should stay responsive even if a file is missing.
        }
    }

    func stopSlideLoop(fadeDuration: TimeInterval = 0.14) {
        guard let name = activeSlideLoopName, let player = loopPlayers[name] else {
            return
        }

        activeSlideLoopName = nil
        player.setVolume(0, fadeDuration: fadeDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration + 0.04) { [weak self, weak player] in
            guard let self, self.loopPlayers[name] === player else {
                return
            }

            player?.stop()
            self.loopPlayers[name] = nil
        }
    }

    private func play(_ name: String, volume: Float, rate: Float = 1) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }

        do {
            configureSessionIfNeeded()
            let player = try players[name] ?? AVAudioPlayer(contentsOf: url)
            player.currentTime = 0
            player.volume = volume
            player.enableRate = true
            player.rate = rate
            player.prepareToPlay()
            player.play()
            players[name] = player
        } catch {
            // Audio is optional; gameplay should stay responsive even if a file is missing.
        }
    }

    private func configureSessionIfNeeded() {
        guard !hasConfiguredSession else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            hasConfiguredSession = true
        } catch {
            hasConfiguredSession = true
        }
    }
}
