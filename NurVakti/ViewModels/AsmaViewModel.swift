import Foundation
import Combine

@MainActor
public class AsmaViewModel: ObservableObject {
    @Published public var names: [EsmaulHusna] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String? = nil
    @Published public var isApiKeyMissing = false
    
    public init() {
        checkApiKey()
    }
    
    private func checkApiKey() {
        let key = APIConfig.islamicAPIKey
        // More robust check: is it empty, too short, or still contains placeholder text?
        if key.isEmpty || key.count < 10 || key.lowercased().contains("your_key") || key.lowercased().contains("placeholder") {
            isApiKeyMissing = true
        } else {
            isApiKeyMissing = false
        }
    }
    
    public func loadNames(language: String = "tr") async {
        guard !isApiKeyMissing else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            self.names = try await AsmaService.shared.fetchNames(language: language)
        } catch {
            self.errorMessage = error.localizedDescription
            // If the error persists, fallback to local data if needed?
        }
        
        isLoading = false
    }
    
    public func retry() async {
        checkApiKey()
        await loadNames()
    }
}
