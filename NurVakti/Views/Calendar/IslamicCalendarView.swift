import SwiftUI

struct IslamicCalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @State private var events: [(event: IslamicEvent, date: Date)] = []
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(events, id: \.event.key) { item in
                            eventRow(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            events = IslamicCalendarService.shared.upcomingEvents(within: 365)
        }
    }
    
    private func eventRow(item: (event: IslamicEvent, date: Date)) -> some View {
        HStack(spacing: 16) {
            // Date Badge
            VStack(spacing: 4) {
                Text(item.date.formatted(.dateTime.day()))
                    .nurFont(20, weight: .bold)
                Text(item.date.formatted(.dateTime.month(.abbreviated)))
                    .nurFont(12, weight: .medium)
                    .textCase(.uppercase)
            }
            .frame(width: 60, height: 60)
            .background(Color.nurGold.opacity(0.15))
            .foregroundColor(.nurGold)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.event.key.name(for: localization.currentLanguage))
                    .nurFont(16, weight: .bold)
                    .foregroundColor(.white)
                
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: item.date).day ?? 0
                Text(daysLeft == 0 ? "Bugün" : "\(daysLeft) gün kaldı")
                    .nurFont(13)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text(item.event.key.emoji)
                .font(.system(size: 30))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
