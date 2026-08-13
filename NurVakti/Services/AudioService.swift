import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
public class AudioService: NSObject {
    public static let shared = AudioService()
    
    private var player: AVPlayer?
    
    // Low-level notifications for status changes
    public let onPlaybackStatusChanged = PassthroughSubject<Bool, Never>()
    public let onBufferingStatusChanged = PassthroughSubject<Bool, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
        setupRemoteCommandCenter()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioService: AVAudioSession config error: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            if self?.player?.timeControlStatus == .playing {
                self?.pause()
            } else {
                self?.resume()
            }
            return .success
        }
    }
    
    // MARK: - Play Methods
    
    public func play(url: URL, title: String? = nil) {
        stop()
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Tracking player status
        player?.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.onPlaybackStatusChanged.send(status == .playing)
                self?.onBufferingStatusChanged.send(status == .waitingToPlayAtSpecifiedRate)
                if let t = title {
                    self?.updateNowPlaying(title: t)
                }
            }
            .store(in: &cancellables)
            
        // Tracking item status for errors
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                if status == .failed {
                    self?.onBufferingStatusChanged.send(false)
                    self?.onPlaybackStatusChanged.send(false)
                }
            }
            .store(in: &cancellables)
            
        player?.play()
        if let t = title {
            updateNowPlaying(title: t)
        }
    }
    
    public func pause() {
        player?.pause()
        onPlaybackStatusChanged.send(false)
    }
    
    public func resume() {
        player?.play()
        onPlaybackStatusChanged.send(true)
    }
    
    public func stop() {
        player?.pause()
        player = nil
        cancellables.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        onPlaybackStatusChanged.send(false)
        onBufferingStatusChanged.send(false)
    }
    
    public func updateNowPlaying(title: String, artist: String = "NurVakti 🕌") {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        if let item = player?.currentItem {
            let duration = CMTimeGetSeconds(item.duration)
            if !duration.isNaN && duration > 0 {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            }
            let currentTime = CMTimeGetSeconds(item.currentTime())
            if !currentTime.isNaN {
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = (player?.rate ?? 0) > 0 ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Delegates & Selectors
    
    @objc private func playerDidFinishPlaying() {
        onPlaybackStatusChanged.send(false)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}
