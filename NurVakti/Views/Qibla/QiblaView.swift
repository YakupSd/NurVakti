import SwiftUI
import CoreLocation

struct QiblaView: View {
    @StateObject private var vm = QiblaViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var persistService: PersistenceService
    @State private var city: String = "..."

    var body: some View {
        ZStack {
            // MARK: - Back Layer
            LinearGradient(colors: [Color(hex: "#0D1B2A"), Color(hex: "#1B263B")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            StarFieldView(opacity: 0.5)

            VStack(spacing: 20) {
                // MARK: - Header Info
                VStack(spacing: 12) {
                    Text(localization.localizedString("qibla.title"))
                        .nurFont(24, weight: .bold)
                        .foregroundColor(.white)
                    
                    Text(city)
                        .nurFont(14, weight: .medium)
                        .foregroundColor(.white.opacity(0.6))
                    
                    VStack(spacing: 4) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.0f°", vm.heading))
                                .nurFont(64, weight: .black)
                                .foregroundColor(.white)
                            Text(currentDirectionString)
                                .nurFont(24, weight: .bold)
                                .foregroundColor(.nurGold)
                                .padding(.bottom, 12)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 12))
                            Text("\(localization.localizedString("qibla.title")): \(String(format: "%.0f°", vm.qiblaAngle)) SE")
                                .nurFont(12, weight: .bold)
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // Accuracy Badge
                    accuracyBadge
                }
                .padding(.top, 40)
                
                Spacer()

                // MARK: - Pro Compass
                ZStack {
                    // Alignment Glow (Perfect alignment effects)
                    if vm.relativeAngle < 15 || vm.relativeAngle > 345 {
                        Circle()
                            .fill(RadialGradient(colors: [Color.nurGold.opacity(0.3), .clear], center: .center, startRadius: 100, endRadius: 180))
                            .frame(width: 360, height: 360)
                            .transition(.opacity)
                    }

                    // Ring Outer Glow
                    Circle()
                        .stroke(Color.nurGold.opacity(0.1), lineWidth: 2)
                        .frame(width: 310, height: 310)

                    // Direction Indicator (Fixed Pointer)
                    VStack {
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.nurGold)
                            .shadow(color: .nurGold.opacity(0.5), radius: 10)
                        Spacer()
                    }
                    .frame(width: 320, height: 320)
                    .zIndex(10)

                    // The Compass Disk (Glassmorphic)
                    CompassDiskView()
                        .rotationEffect(.degrees(-vm.heading))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.heading)
                    
                    // Kaaba Indicator
                    KaabaPointerView(angle: vm.qiblaAngle)
                        .rotationEffect(.degrees(-vm.heading))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.heading)
                }
                .frame(width: 320, height: 320)
                .scaleEffect(vm.relativeAngle < 5 || vm.relativeAngle > 355 ? 1.05 : 1.0)
                .animation(.spring(), value: vm.relativeAngle)
                
                Spacer()
                
                // MARK: - Calibration / Footer
                if vm.isCalibrating {
                    calibrationBanner
                } else {
                    Text(localization.localizedString("qibla.calibrateHint"))
                        .nurFont(12)
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .onAppear { 
            vm.startTracking()
            Task {
                if let loc = CLLocationManager().location {
                    let service = LocationService()
                    self.city = await service.resolveCity(for: loc)
                }
            }
        }
        .onDisappear { vm.stopTracking() }
    }

    // MARK: - Components
    
    private var currentDirectionString: String {
        let angle = vm.heading
        if angle < 22.5 || angle >= 337.5 { return "N" }
        if angle < 67.5 { return "NE" }
        if angle < 112.5 { return "E" }
        if angle < 157.5 { return "SE" }
        if angle < 202.5 { return "S" }
        if angle < 247.5 { return "SW" }
        if angle < 292.5 { return "W" }
        return "NW"
    }

    private var accuracyBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accuracyColor)
                .frame(width: 8, height: 8)
            Text(accuracyLabel)
                .nurFont(12, weight: .bold)
                .foregroundColor(accuracyColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(accuracyColor.opacity(0.1))
        .cornerRadius(20)
    }

    private var accuracyColor: Color {
        if vm.accuracy < 0 { return .gray }
        if vm.accuracy < 15 { return .green }
        if vm.accuracy < 30 { return .orange }
        return .red
    }

    private var accuracyLabel: String {
        if vm.accuracy < 0 { return "---" }
        if vm.accuracy < 15 { return localization.localizedString("qibla.veryAccurate") }
        if vm.accuracy < 30 { return localization.localizedString("qibla.accurate") }
        return localization.localizedString("qibla.lowAccuracy")
    }

    private var calibrationBanner: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint(.orange)
            Text(localization.localizedString("qibla.calibrate"))
                .nurFont(12, weight: .bold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Compass Disk
struct CompassDiskView: View {
    var body: some View {
        ZStack {
            // Main Disk - Glassmorphism
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            
            // Decorative Inner Patterns
            Circle()
                .stroke(Color.nurGold.opacity(0.1), lineWidth: 1)
                .padding(40)
            
            // Marks
            ForEach(0..<72) { i in
                Rectangle()
                    .fill(i % 18 == 0 ? Color.nurGold : Color.white.opacity(0.3))
                    .frame(width: i % 18 == 0 ? 3 : 1, height: i % 18 == 0 ? 18 : 10)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(i) * 5))
            }
            
            // Labels (N, E, S, W)
            Group {
                Text("N").offset(y: -110)
                Text("E").offset(x: 110)
                Text("S").offset(y: 110)
                Text("W").offset(x: -110)
            }
            .nurFont(16, weight: .black)
            .foregroundColor(.white)
        }
        .frame(width: 300, height: 300)
    }
}

// MARK: - Kaaba Pointer
struct KaabaPointerView: View {
    let angle: Double
    
    var body: some View {
        ZStack {
            // Pointer Line to center
            Rectangle()
                .fill(LinearGradient(colors: [.nurGold, .clear], startPoint: .top, endPoint: .bottom))
                .frame(width: 2, height: 100)
                .offset(y: -50)
            
            // Kaaba Icon with Fallback
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.nurGold.opacity(0.2))
                        .frame(width: 54, height: 54)
                        .blur(radius: 5)
                    
                    Image("KaabaIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .shadow(color: .nurGold.opacity(0.5), radius: 10)
                }
                .offset(y: -125)
                Spacer()
            }
        }
        .frame(width: 300, height: 300)
        .rotationEffect(.degrees(angle))
    }
}

#Preview {
    QiblaView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(PersistenceService.shared)
}

// MARK: - Helpers
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
