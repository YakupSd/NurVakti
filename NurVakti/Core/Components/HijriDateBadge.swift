import SwiftUI

struct HijriDateBadge: View {
    let hijriDate: HijriDate
    let miladi: Date
    let language: LanguageCode
    let fontSize: FontSize
    
    var body: some View {
        VStack(alignment: language.isRTL ? .trailing : .leading, spacing: 4) {
            Text(hijriDate.formatted(for: language))
                .font(.system(size: fontSize.body, weight: .bold))
                .foregroundColor(.nurGold)
            
            Text(miladiFormatter.string(from: miladi))
                .font(.system(size: fontSize.caption))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white.opacity(0.1))
        .cornerRadius(12)
        .environment(\.layoutDirection, language.isRTL ? .rightToLeft : .leftToRight)
    }
    
    private var miladiFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = language.locale
        return formatter
    }
}

#Preview {
    HijriDateBadge(hijriDate: HijriDate(day: 15, month: 9, year: 1446), miladi: Date(), language: .tr, fontSize: .medium)
        .padding()
        .background(Color.black)
}
