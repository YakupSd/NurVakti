import SwiftUI

// MARK: - Premium Special Day Banner View
struct SpecialDayBannerView: View {
    let info: SpecialDayInfo
    let action: () -> Void

    @State private var isPulsing = false
    @State private var shareSheetItem: SpiritualMessage? = nil

    init(info: SpecialDayInfo, action: @escaping () -> Void) {
        self.info = info
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.tap()
            action()
        }) {
            ZStack(alignment: .topTrailing) {
                // Background Gradient with Islamic ambient glow
                VStack(alignment: .leading, spacing: 10) {
                    // Top: Tag + Badge
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text(info.emoji)
                                .font(.system(size: 14))
                            Text(info.badgeText)
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(info.accentColor.opacity(0.25))
                        )
                        .overlay(
                            Capsule()
                                .stroke(info.accentColor.opacity(0.5), lineWidth: 0.8)
                        )

                        Spacer()

                        // Quick Share Button
                        Button(action: {
                            HapticManager.shared.light()
                            quickShareSpecialDay()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Paylaş")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }

                    // Main Title
                    Text(info.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)

                    // Subtitle / Description
                    Text(info.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(3)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)

                    // Bottom Action Strip
                    HStack(spacing: 6) {
                        Text(info.actionTitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(info.accentColor)

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(info.accentColor)
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            colors: info.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        // Ambient glow in corner
                        Circle()
                            .fill(info.accentColor.opacity(isPulsing ? 0.22 : 0.12))
                            .frame(width: 140, height: 140)
                            .blur(radius: 28)
                            .offset(x: 100, y: -40)
                    }
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: info.borderGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: info.accentColor.opacity(0.22), radius: 12, x: 0, y: 5)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .sheet(item: $shareSheetItem) { msg in
            SpiritualShareSheet(message: msg)
        }
    }

    private func quickShareSpecialDay() {
        let msg = SpiritualMessageService.shared.todaysFeaturedMessage()
        self.shareSheetItem = msg
    }
}
