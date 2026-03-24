import SwiftUI

// MARK: - Empty State Types
enum EmptyStateType {
    case prayerTimesUnavailable   // Konum yok, vakit yok
    case quranSearchNoResults     // Arama sonucu yok
    case noBookmarks              // Henüz yer işareti yok
    case noDhikrItems             // Zikir listesi boş (beklenmiyor ama güvenli)
    case noAlarms                 // Alarm kurulmamış

    var icon: String {
        switch self {
        case .prayerTimesUnavailable: return "moon.zzz.fill"
        case .quranSearchNoResults:   return "magnifyingglass"
        case .noBookmarks:            return "bookmark.slash"
        case .noDhikrItems:           return "circle.dotted"
        case .noAlarms:               return "bell.slash"
        }
    }

    func title(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.prayerTimesUnavailable, .tr): return "Vakit Bilgisi Yok"
        case (.prayerTimesUnavailable, .en): return "No Prayer Times"
        case (.prayerTimesUnavailable, .ar): return "لا توجد أوقات صلاة"

        case (.quranSearchNoResults, .tr):   return "Sonuç Bulunamadı"
        case (.quranSearchNoResults, .en):   return "No Results Found"
        case (.quranSearchNoResults, .ar):   return "لا توجد نتائج"

        case (.noBookmarks, .tr):            return "Henüz Yer İşareti Yok"
        case (.noBookmarks, .en):            return "No Bookmarks Yet"
        case (.noBookmarks, .ar):            return "لا توجد إشارات مرجعية"

        case (.noDhikrItems, .tr):           return "Zikir Listesi Boş"
        case (.noDhikrItems, .en):           return "Dhikr List Empty"

        case (.noAlarms, .tr):               return "Alarm Kurulmamış"
        case (.noAlarms, .en):               return "No Alarms Set"
        case (.noAlarms, .ar):               return "لم يتم تعيين تنبيهات"

        default: return "İçerik Bulunamadı"
        }
    }

    func subtitle(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.prayerTimesUnavailable, .tr):
            return "Konumunuzu etkinleştirdiğinizde vakitler burada görünecek."
        case (.prayerTimesUnavailable, .en):
            return "Enable your location to see prayer times here."

        case (.quranSearchNoResults, .tr):
            return "Farklı bir sure adı veya numarası deneyin."
        case (.quranSearchNoResults, .en):
            return "Try a different surah name or number."
        case (.quranSearchNoResults, .ar):
            return "جرب اسم سورة أو رقمًا مختلفًا."

        case (.noBookmarks, .tr):
            return "Bir ayeti uzun basarak yer işareti ekleyebilirsiniz."
        case (.noBookmarks, .en):
            return "Long press an ayah to add a bookmark."

        case (.noAlarms, .tr):
            return "Vakit bildirimleri almak için alarm kurabilirsiniz."
        case (.noAlarms, .en):
            return "Set up alarms to receive prayer time notifications."

        default: return ""
        }
    }

    func actionTitle(for language: LanguageCode) -> String? {
        switch (self, language) {
        case (.noAlarms, .tr):   return "Alarm Ekle"
        case (.noAlarms, .en):   return "Add Alarm"
        case (.noAlarms, .ar):   return "إضافة تنبيه"
        default: return nil
        }
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let type: EmptyStateType
    let language: LanguageCode
    var onAction: (() -> Void)? = nil

    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Animasyonlu İkon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 110, height: 110)
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 130, height: 130)
                Image(systemName: type.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.nurGold.opacity(0.7), Color.white.opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    iconScale = 1.0
                    iconOpacity = 1.0
                }
            }

            // Metin
            VStack(spacing: 10) {
                Text(type.title(for: language))
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                let sub = type.subtitle(for: language)
                if !sub.isEmpty {
                    Text(sub)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
            }

            // Opsiyonel Aksiyon Butonu
            if let actionTitle = type.actionTitle(for: language), let onAction = onAction {
                NurButton(title: actionTitle, style: .secondary, fontSize: .medium, action: onAction)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding()
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityElement(children: .combine)
        .accessibilityLabel(type.title(for: language))
        .accessibilityHint(type.subtitle(for: language))
    }
}

#Preview {
    ZStack {
        Color(hex: "0D1B2A").ignoresSafeArea()
        VStack {
            EmptyStateView(type: .quranSearchNoResults, language: .tr)
            EmptyStateView(type: .noBookmarks, language: .tr)
        }
    }
}
