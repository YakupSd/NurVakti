import Foundation
import AVFoundation
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
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // MARK: - Play Methods
    
    public func play(url: URL) {
        stop()
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Tracking player status
        player?.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.onPlaybackStatusChanged.send(status == .playing)
                self?.onBufferingStatusChanged.send(status == .waitingToPlayAtSpecifiedRate)
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
    }
    
    public func stop() {
        player?.pause()
        player = nil
        cancellables.removeAll()
        
        onPlaybackStatusChanged.send(false)
        onBufferingStatusChanged.send(false)
    }
    
    // MARK: - Delegates & Selectors
    
    @objc private func playerDidFinishPlaying() {
        onPlaybackStatusChanged.send(false)
    }
}
