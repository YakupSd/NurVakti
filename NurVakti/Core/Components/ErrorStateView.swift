import SwiftUI

// MARK: - Error Types
enum NurError {
    case locationDenied
    case locationUnavailable
    case networkFailed
    case prayerCalcFailed
    case quranLoadFailed
    case unknown(String)

    var icon: String {
        switch self {
        case .locationDenied:      return "location.slash.fill"
        case .locationUnavailable: return "location.fill.viewfinder"
        case .networkFailed:       return "wifi.slash"
        case .prayerCalcFailed:    return "moon.stars.fill"
        case .quranLoadFailed:     return "book.closed.fill"
        case .unknown:             return "exclamationmark.triangle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .locationDenied, .locationUnavailable: return .orange
        case .networkFailed: return .red
        default: return .nurGold
        }
    }

    func title(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.locationDenied, .tr):    return "Konum İzni Gerekli"
        case (.locationDenied, .en):    return "Location Permission Needed"
        case (.locationDenied, .ar):    return "إذن الموقع مطلوب"
        case (.locationDenied, .de):    return "Standortberechtigung benötigt"
        case (.locationDenied, .pt):    return "Permissão de Localização Necessária"

        case (.networkFailed, .tr):     return "İnternet Bağlantısı Yok"
        case (.networkFailed, .en):     return "No Internet Connection"
        case (.networkFailed, .ar):     return "لا يوجد اتصال بالإنترنت"
        case (.networkFailed, .de):     return "Keine Internetverbindung"
        case (.networkFailed, .pt):     return "Sem Conexão com a Internet"

        case (.prayerCalcFailed, .tr):  return "Vakit Hesabı Başarısız"
        case (.prayerCalcFailed, .en):  return "Prayer Time Calculation Failed"
        case (.prayerCalcFailed, .ar):  return "فشل حساب أوقات الصلاة"

        case (.quranLoadFailed, .tr):   return "Kur'an Yüklenemedi"
        case (.quranLoadFailed, .en):   return "Could Not Load Quran"
        case (.quranLoadFailed, .ar):   return "تعذر تحميل القرآن"

        default: return "Bir Hata Oluştu"
        }
    }

    func message(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.locationDenied, .tr):
            return "Namaz vakitlerinizi görebilmek için konum iznine ihtiyacımız var. Ayarlardan izin verebilirsiniz."
        case (.locationDenied, .en):
            return "We need location permission to calculate your prayer times. You can grant it in Settings."
        case (.locationDenied, .ar):
            return "نحتاج إلى إذن الموقع لحساب أوقات الصلاة."

        case (.networkFailed, .tr):
            return "İnternete bağlanılamıyor. Wi-Fi veya mobil veri bağlantınızı kontrol edin."
        case (.networkFailed, .en):
            return "Cannot connect to the internet. Please check your Wi-Fi or mobile data."
        case (.networkFailed, .ar):
            return "لا يمكن الاتصال بالإنترنت. تحقق من Wi-Fi أو البيانات الجوالة."

        case (.prayerCalcFailed, .tr):
            return "Konumunuz için vakit hesabı yapılamadı. Lütfen tekrar deneyin."
        case (.prayerCalcFailed, .en):
            return "Could not calculate prayer times for your location. Please try again."

        case (.quranLoadFailed, .tr):
            return "Kur'an sayfaları yüklenirken bir sorun oluştu. İnternet bağlantınızı kontrol edin."
        case (.quranLoadFailed, .en):
            return "There was a problem loading Quran pages. Check your connection."

        default: return "Lütfen tekrar deneyin."
        }
    }

    func actionTitle(for language: LanguageCode) -> String {
        switch (self, language) {
        case (.locationDenied, .tr):  return "Ayarları Aç"
        case (.locationDenied, .en):  return "Open Settings"
        case (.locationDenied, .ar):  return "فتح الإعدادات"
        case (.networkFailed, _):     return language == .tr ? "Yenile" : "Retry"
        default:                      return language == .tr ? "Tekrar Dene" : "Try Again"
        }
    }
}

// MARK: - Equatable
extension NurError: Equatable {
    static func == (lhs: NurError, rhs: NurError) -> Bool {
        switch (lhs, rhs) {
        case (.locationDenied, .locationDenied),
             (.locationUnavailable, .locationUnavailable),
             (.networkFailed, .networkFailed),
             (.prayerCalcFailed, .prayerCalcFailed),
             (.quranLoadFailed, .quranLoadFailed): return true
        case (.unknown(let a), .unknown(let b)):   return a == b
        default: return false
        }
    }
}

// MARK: - ErrorStateView
struct ErrorStateView: View {
    let error: NurError
    let language: LanguageCode
    /// locationDenied → iOS Settings açılır otomatik. Diğerleri için retry action beklenir.
    var onAction: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // İkon
            ZStack {
                Circle()
                    .fill(error.iconColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: error.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [error.iconColor, error.iconColor.opacity(0.6)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            // Metin
            VStack(spacing: 12) {
                Text(error.title(for: language))
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(error.message(for: language))
                    .font(.body)
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            // Aksiyon
            VStack(spacing: 12) {
                NurButton(
                    title: error.actionTitle(for: language),
                    icon: error == .locationDenied ? "gear" : "arrow.clockwise",
                    style: .primary,
                    fontSize: .large
                ) {
                    if error == .locationDenied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } else {
                        onAction?()
                    }
                }

                if let onDismiss = onDismiss {
                    Button(language == .tr ? "Atla" : "Skip") { onDismiss() }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
        .padding()
        // ── Accessibility ──────────────────────────────────────────
        .accessibilityElement(children: .contain)
        .accessibilityLabel(error.title(for: language))
        .accessibilityHint(error.message(for: language))
    }
}

#Preview {
    ZStack {
        Color(hex: "0D1B2A").ignoresSafeArea()
        ErrorStateView(error: .networkFailed, language: .tr)
    }
}
