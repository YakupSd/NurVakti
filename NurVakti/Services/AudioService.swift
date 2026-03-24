import Foundation
import AVFoundation
import Combine

class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var player: AVPlayer?
    
    @Published var isPlaying = false
    @Published var isBuffering = false
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // MARK: - Play Methods
    
    func speak(_ text: String, language: String) {
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        if language.starts(with: "ar") {
            utterance.rate = 0.45
        } else {
            utterance.rate = 0.5
        }
        
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func playStream(urlStr: String) {
        guard let url = URL(string: urlStr) else { return }
        stop()
        
        isBuffering = true
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Listen to player status
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isBuffering = false
                    self?.player?.play()
                    self?.isPlaying = true
                    print("🔊 Audio ready and playing")
                case .failed:
                    self?.isBuffering = false
                    self?.isPlaying = false
                    if let error = playerItem.error {
                        print("❌ Audio session failed: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
            
        // Background play support (basic)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func stop() {
        // Stop TTS
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Stop Player
        player?.pause()
        player = nil
        cancellables.removeAll()
        
        isPlaying = false
        isBuffering = false
    }
    
    // MARK: - Delegates & Selectors
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
