import SwiftUI

struct QiblaView: View {
    @StateObject private var vm = QiblaViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            // Arka Plan
            LinearGradient(colors: [Color(hex: "#0D1B2A"), Color(hex: "#1a2f50")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            StarFieldView(opacity: 0.6)

            VStack(spacing: 40) {
                Spacer()

                Spacer()

                // ─── Kalibrasyon Uyarısı ───
                if vm.isCalibrating {
                    calibrationBanner
                }

                // ─── Pusula + İbre ───
                ZStack {
                    // Dış halka glow
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.nurGold.opacity(0.08), .clear],
                                           center: .center, startRadius: 0, endRadius: 180)
                        )
                        .frame(width: 360, height: 360)

                    // Dış halka
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        .frame(width: 320, height: 320)

                    // Yön işaretleri (N, E, S, W)
                    ForEach(compassLabels, id: \.label) { item in
                        Text(item.label)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .offset(y: -135)
                            .rotationEffect(.degrees(item.angle))
                    }

                    // Derece çizgileri
                    ForEach(0..<72) { i in
                        Rectangle()
                            .fill(Color.white.opacity(i % 9 == 0 ? 0.4 : 0.1))
                            .frame(width: 1, height: i % 9 == 0 ? 12 : 6)
                            .offset(y: -148)
                            .rotationEffect(.degrees(Double(i) * 5))
                    }

                    // ─── Kıble İbresi ───
                    QiblaCompassNeedle()
                        .rotationEffect(.degrees(vm.relativeAngle))
                        .animation(.interpolatingSpring(stiffness: 50, damping: 10),
                                   value: vm.relativeAngle)
                }
                .frame(width: 320, height: 320)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(compassAccessibilityLabel)

                // ─── Açı Bilgisi ───
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.north.fill")
                            .foregroundColor(.nurGold)
                        Text(String(format: "%.1f°", vm.qiblaAngle))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    Text(accuracyLabel)
                        .font(.caption)
                        .foregroundColor(vm.accuracy >= 0 && vm.accuracy < 15
                                         ? .green : .orange)
                }

                Spacer()
            }
        }
        .onAppear { vm.startTracking() }
        .onDisappear { vm.stopTracking() }
    }

    // MARK: - Sub Views

    private var calibrationBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.orange)
            Text(localization.localizedString("qibla.calibrate"))
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(12)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private var compassLabels: [(label: String, angle: Double)] {
        [
            (localization.localizedString("qibla.north"), 0),
            (localization.localizedString("qibla.east"), 90),
            (localization.localizedString("qibla.south"), 180),
            (localization.localizedString("qibla.west"), 270)
        ]
    }

    private var accuracyLabel: String {
        guard vm.accuracy >= 0 else { return localization.localizedString("alarm.disabled") } // Or a better key
        if vm.accuracy < 5  { return "✓ \(localization.localizedString("qibla.veryAccurate")) (\(Int(vm.accuracy))°)" }
        if vm.accuracy < 15 { return "✓ \(localization.localizedString("qibla.accurate")) (\(Int(vm.accuracy))°)" }
        return "⚠ \(localization.localizedString("qibla.lowAccuracy")) (\(Int(vm.accuracy))°)"
    }

    private var compassAccessibilityLabel: String {
        return localization.localizedString("a11y.qiblaCompass").replacingOccurrences(of: "%d", with: "\(Int(vm.qiblaAngle))")
    }
}

// MARK: - Kıble İbresi Componenti
struct QiblaCompassNeedle: View {
    var body: some View {
        ZStack {
            // Kuzey (kıble yönü — altın)
            Triangle()
                .fill(
                    LinearGradient(colors: [.nurGoldLight, .nurGold],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 24, height: 100)
                .offset(y: -55)
                .shadow(color: .nurGold.opacity(0.5), radius: 8)

            // Güney (gri, kıble karşısı)
            Triangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 24, height: 80)
                .rotationEffect(.degrees(180))
                .offset(y: 44)

            // Merkez daire
            Circle()
                .fill(Color.nurGold)
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))

            // Kabe ikonu
            Image(systemName: "building.2.fill")
                .font(.system(size: 9))
                .foregroundColor(.black)
                .offset(y: -65)
        }
    }
}

// MARK: - Üçgen shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    QiblaView()
        .environmentObject(LocalizationManager.shared)
}
