//
//  PlayerViewController.swift
//  MusicPlayer
//
//  Created by Kazykhan Mukhamedali on 30.10.2026.
//

import UIKit
import AVFoundation

final class PlayerViewController: UIViewController {

    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!
    
    @IBOutlet private weak var progressSlider: UISlider!
    
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!

    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var player: AVAudioPlayer?
    private var timer: Timer?

    private var currentTrack: Track { tracks[currentIndex] }
    private var isPlaying: Bool { player?.isPlaying ?? false }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        configureControls()
        loadTrack(at: 0, autoplay: false)
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        guard let player else { return }
        
        if player.isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        refreshPlayPauseButton()
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
            player?.currentTime = TimeInterval(sender.value)
        }

    @IBAction private func nextTapped(_ sender: UIButton) {
        let wasPlaying = isPlaying
        let nextIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: nextIndex, autoplay: wasPlaying)
    }

    @IBAction private func previousTapped(_ sender: UIButton) {
        let wasPlaying = isPlaying
        let prevIndex = (currentIndex - 1 + tracks.count) % tracks.count
        loadTrack(at: prevIndex, autoplay: wasPlaying)
    }

    
    private func loadTrack(at index: Int, autoplay: Bool) {
        guard tracks.indices.contains(index) else { return }

        currentIndex = index
        updateTrackInfo()
        stopTimer()
        progressSlider.value = 0

        
        guard let url = audioURL(for: currentTrack) else {
            player = nil
            refreshPlayPauseButton()
            presentError("Audio file \(currentTrack.fileName) not found in the app bundle.")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    
                    do {
                        let newPlayer = try AVAudioPlayer(contentsOf: url)
                        newPlayer.delegate = self
                        newPlayer.prepareToPlay()
                        
                        DispatchQueue.main.async {
                            self.player = newPlayer
                            self.progressSlider.maximumValue = Float(newPlayer.duration)
                            if autoplay {
                                newPlayer.play()
                                self.startTimer()
                            }
                            self.refreshPlayPauseButton()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.player = nil
                            self.presentError("Playback error: \(error.localizedDescription)")
                        }
                    }
                }
    }

    private func audioURL(for track: Track) -> URL? {
        for ext in ["mp3", "m4a"] {
            if let url = Bundle.main.url(forResource: track.fileName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    
    private func startTimer() {
            stopTimer()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.player else { return }
                self.progressSlider.value = Float(player.currentTime)
            }
        }

        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

    private func updateTrackInfo() {
        titleLabel.text = currentTrack.title
        artistLabel.text = currentTrack.artist
        coverImageView.image = UIImage(named: currentTrack.coverImageName) ?? UIImage(systemName: "music.note")
    }

    private func refreshPlayPauseButton() {
        setSymbol(isPlaying ? "pause.fill" : "play.fill", on: playPauseButton)
    }

    private func configureControls() {
        setSymbol("backward.fill", on: previousButton)
        setSymbol("play.fill", on: playPauseButton)
        setSymbol("forward.fill", on: nextButton)

        coverImageView.layer.cornerRadius = 16
        coverImageView.clipsToBounds = true
    }

    private func setSymbol(_ name: String, on button: UIButton, pointSize: CGFloat = 34) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        let image = UIImage(systemName: name, withConfiguration: config)
        
        if var buttonConfig = button.configuration {
            buttonConfig.image = image
            button.configuration = buttonConfig
        } else {
            button.setImage(image, for: .normal)
        }
    }

    private func configureAudioSession() {
            DispatchQueue.global(qos: .background).async {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(.playback, mode: .default)
                    try session.setActive(true)
                } catch {
                    print("⚠️ Audio session error: \(error)")
                }
            }
        }

    private func presentError(_ message: String) {
        print("⚠️ \(message)")
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            refreshPlayPauseButton()
            return
        }
        let nextIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: nextIndex, autoplay: true)
    }
}
