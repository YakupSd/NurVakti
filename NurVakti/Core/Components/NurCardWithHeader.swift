import SwiftUI

struct NurCardWithHeader: View {
    let title: String
    let icon: String
    let content: DailyContent
    @EnvironmentObject var localization: LocalizationManager
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title.uppercased(), systemImage: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.nurGold)
                    .tracking(1.5)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Copy Button
                    Button(action: { 
                        HapticManager.shared.light()
                        UIPasteboard.general.string = content.translation(for: localization.currentLanguage) 
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            .padding(6)
                            .background(ColorColor(hex: "1A1A2E").opacity(0.08))
                            .clipShape(Circle())
                    }

                    Button(action: { 
                        HapticManager.shared.tap()
                        showShareSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 10))
                            Text(localization.localizedString("general.share"))
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.nurGold)
                        .cornerRadius(10)
                    }
                }
            }
            
            Text(content.arabicText)
                .font(.custom("KFGQPCUthmanicScriptHAFS", size: 26))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .foregroundColor(Color(hex: "1A1A2E"))
                .lineSpacing(6)
            
            Divider().background(ColorColor(hex: "1A1A2E").opacity(0.1)).padding(.vertical, 4)
            
            Text(content.translation(for: localization.currentLanguage))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.7))
                .italic()
                .lineSpacing(4)
            
            Text(content.source)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.nurGold.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorColor(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
        )
        .sheet(isPresented: $showShareSheet) {
            GuidanceShareSheet(content: content)
        }
    }
}
