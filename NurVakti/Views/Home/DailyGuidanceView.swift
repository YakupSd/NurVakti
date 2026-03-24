import SwiftUI

struct DailyGuidanceView: View {
    let item: GuidanceItem
    let language: LanguageCode
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: item.type == .ayat ? "quote.bubble.fill" : "person.fill.viewfinder")
                    .foregroundColor(.nurGold)
                Text(item.type == .ayat ? LocalizationManager.shared.localizedString("guidance.dailyAyat") : LocalizationManager.shared.localizedString("guidance.dailyHadith"))
                    .nurFont(14, weight: .bold)
                    .foregroundColor(.nurGold)
                Spacer()
                
                Button(action: shareContent) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal)
            
            // Content
            Text(item.text)
                .nurFont(20, weight: .medium)
                .italic()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            // Source
            if let source = item.source {
                Text(source)
                    .nurFont(12, weight: .light)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                Color.black.opacity(0.3)
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                
                // Dekoratif desen
                Image(systemName: "seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.nurGold.opacity(0.03))
                    .offset(x: 120, y: 40)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .sheet(isPresented: $showingShareSheet) {
            GuidanceShareSheet(item: item)
        }
    }
    
    @State private var showingShareSheet = false
    
    private func shareContent() {
        showingShareSheet = true
    }
}
