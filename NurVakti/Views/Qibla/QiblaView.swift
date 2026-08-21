import SwiftUI
import CoreLocation

struct QiblaView: View {
    @StateObject private var vm = QiblaViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var persistService: PersistenceService
    @State private var city: String = "..."

    var isAligned: Bool {
        vm.relativeAngle < 3.5 || vm.relativeAngle > 356.5
    }

    var body: some View {
        ZStack {
            // Background — Warm Cream Light Luxury
            Color(hex: "F8F6F0").ignoresSafeArea()

            VStack(spacing: 12) {
                // MARK: - 1. Top Header Info
                headerSection
                    .padding(.top, 8)
                
                Spacer()

                // MARK: - 2. Luxury Astrolabe Compass
                ZStack {
                    // Alignment Halo Glow
                    if isAligned {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#10B981").opacity(0.35),
                                        Color.nurGold.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 80,
                                    endRadius: 200
                                )
                            )
                            .frame(width: 360, height: 360)
                            .transition(.opacity)
                    }

                    // Luxury Compass Dial
                    LuxuryAstrolabeCompass(
                        heading: vm.heading,
                        qiblaAngle: vm.qiblaAngle,
                        isAligned: isAligned,
                        pitch: vm.pitch,
                        roll: vm.roll
                    )
                }
                .frame(width: 320, height: 320)
                .scaleEffect(isAligned ? 1.03 : 1.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isAligned)
                
                Spacer()
                
                // MARK: - 3. Live Metrics & Guidance Card
                bottomMetricsSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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
        .onDisappear { 
            vm.stopTracking() 
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Location Badge
            if !city.isEmpty && city != "..." {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.nurGold)
                    Text(city)
                        .nurFont(14, weight: .bold)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.75))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, y: 1)
            }
            
            // Current Heading & Direction
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(String(format: "%.0f°", vm.heading))
                    .nurFont(54, weight: .black, design: .rounded)
                    .foregroundColor(Color(hex: "1A1A2E"))
                
                Text(currentDirectionString)
                    .nurFont(22, weight: .heavy, design: .rounded)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "D4AF37"), Color(hex: "996515")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 6)
            }
            
            // Live Turn / Alignment Guidance Pill
            guidanceBadge
        }
    }
    
    // MARK: - Live Dynamic Guidance Badge
    @ViewBuilder
    private var guidanceBadge: some View {
        let instruction = vm.turnInstruction
        
        HStack(spacing: 8) {
            if isAligned {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Kâbe'ye Doğru Hizalandı ✨")
                    .nurFont(13, weight: .bold)
                    .foregroundColor(.white)
            } else {
                Image(systemName: instruction.isRight ? "arrow.turn.up.right" : "arrow.turn.up.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.nurGold)
                
                Text(instruction.text)
                    .nurFont(13, weight: .bold)
                    .foregroundColor(Color(hex: "1A1A2E"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                if isAligned {
                    LinearGradient(
                        colors: [Color(hex: "#10B981"), Color(hex: "#059669")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.white
                }
            }
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isAligned ? Color.white.opacity(0.4) : Color.nurGold.opacity(0.3),
                    lineWidth: 1.2
                )
        )
        .shadow(
            color: isAligned ? Color(hex: "#10B981").opacity(0.35) : Color.black.opacity(0.04),
            radius: 8,
            y: 3
        )
    }

    // MARK: - Bottom Metrics Section
    private var bottomMetricsSection: some View {
        VStack(spacing: 10) {
            // Flat Phone Warning if tilted
            if !vm.isPhoneFlat {
                HStack(spacing: 8) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.orange)
                        .font(.system(size: 13, weight: .bold))
                    Text("Daha doğru ölçüm için telefonu düz tutun")
                        .nurFont(12, weight: .semibold)
                        .foregroundColor(Color(hex: "1A1A2E").opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(12)
                .transition(.opacity)
            }
            
            // 3 Metric Cards
            HStack(spacing: 12) {
                // 1. Distance to Makkah
                metricCard(
                    icon: "map.fill",
                    title: "Kâbe Mesafesi",
                    value: vm.formattedDistance,
                    accentColor: .nurGold
                )
                
                // 2. Qibla Bearing Angle
                metricCard(
                    icon: "safari.fill",
                    title: "Kıble Açısı",
                    value: String(format: "%.0f°", vm.qiblaAngle),
                    accentColor: Color(hex: "#10B981")
                )
                
                // 3. Accuracy
                metricCard(
                    icon: "sparkles",
                    title: "Hassasiyet",
                    value: vm.accuracy >= 0 ? "±\(Int(vm.accuracy))°" : "Aktif",
                    accentColor: Color(hex: "#3B82F6")
                )
            }
        }
    }
    
    private func metricCard(icon: String, title: String, value: String, accentColor: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(accentColor)
                Text(title)
                    .nurFont(10, weight: .semibold)
                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.55))
            }
            
            Text(value)
                .nurFont(15, weight: .bold, design: .rounded)
                .foregroundColor(Color(hex: "1A1A2E"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
    }

    // MARK: - Direction String
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
}

// MARK: - Luxury Astrolabe & Modern Compass View
struct LuxuryAstrolabeCompass: View {
    let heading: Double
    let qiblaAngle: Double
    let isAligned: Bool
    let pitch: Double
    let roll: Double
    
    var body: some View {
        ZStack {
            // 1. Outer Brass/Gold Bezel Ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F4E4BA"),
                            Color(hex: "#D4AF37"),
                            Color(hex: "#AA7C11"),
                            Color(hex: "#E5C158")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 316, height: 316)
                .shadow(color: Color.black.opacity(0.12), radius: 18, y: 8)
                .shadow(color: Color.nurGold.opacity(0.2), radius: 8, y: 2)
            
            // 2. Outer Bezel Groove
            Circle()
                .stroke(Color(hex: "#8A5A00").opacity(0.3), lineWidth: 1.5)
                .frame(width: 308, height: 308)

            // 3. The Rotating Pearl Dial
            RotatingCompassDial(isAligned: isAligned)
                .frame(width: 296, height: 296)
                .rotationEffect(.degrees(-heading))
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: heading)
            
            // 4. Rotating Kaaba Beacon Needle (Anchored to exact Qibla bearing)
            KaabaBeaconNeedle(isAligned: isAligned)
                .frame(width: 296, height: 296)
                .rotationEffect(.degrees(qiblaAngle - heading))
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: heading)

            // 5. Fixed Top Alignment Pointer (Triangle Marker)
            VStack {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(isAligned ? Color(hex: "#10B981") : Color.nurGold)
                    .shadow(
                        color: (isAligned ? Color(hex: "#10B981") : Color.nurGold).opacity(0.5),
                        radius: 6
                    )
                    .offset(y: -4)
                Spacer()
            }
            .frame(width: 316, height: 316)
            .zIndex(20)
            
            // 6. Center Bubble Level (Su Terazisi)
            SpiritBubbleLevel(pitch: pitch, roll: roll, isAligned: isAligned)
                .zIndex(30)
        }
    }
}

// MARK: - Rotating Compass Dial (Pearl & Seljuk Star Core)
struct RotatingCompassDial: View {
    let isAligned: Bool
    
    var body: some View {
        ZStack {
            // Pearl Base
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "#FCFAF6"), Color(hex: "#F5EFE6")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: "1A1A2E").opacity(0.08), lineWidth: 1)
                )
            
            // Subtle Islamic 8-Pointed Star Rosette
            IslamicStarRosette()
                .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                .frame(width: 140, height: 140)
            
            // Inner Compass Ring
            Circle()
                .stroke(Color.nurGold.opacity(0.25), lineWidth: 1)
                .frame(width: 210, height: 210)
            
            // Degree Tick Marks (Every 5°, major every 30°)
            ForEach(0..<72) { i in
                let isMajor = i % 6 == 0
                let isQuarter = i % 18 == 0
                
                Rectangle()
                    .fill(
                        isQuarter ? Color(hex: "#1A1A2E") : (isMajor ? Color.nurGold : Color(hex: "1A1A2E").opacity(0.2))
                    )
                    .frame(
                        width: isQuarter ? 2.5 : (isMajor ? 1.8 : 1),
                        height: isQuarter ? 14 : (isMajor ? 10 : 6)
                    )
                    .offset(y: -136)
                    .rotationEffect(.degrees(Double(i) * 5))
            }
            
            // Cardinal Points (N, E, S, W)
            Group {
                // North (Red Accent)
                VStack {
                    Text("N")
                        .nurFont(16, weight: .black, design: .rounded)
                        .foregroundColor(Color(hex: "#EF4444"))
                    Spacer()
                }
                .frame(height: 242)
                
                // East
                HStack {
                    Spacer()
                    Text("E")
                        .nurFont(15, weight: .bold, design: .rounded)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .frame(width: 242)
                
                // South
                VStack {
                    Spacer()
                    Text("S")
                        .nurFont(15, weight: .bold, design: .rounded)
                        .foregroundColor(Color(hex: "1A1A2E"))
                }
                .frame(height: 242)
                
                // West
                HStack {
                    Text("W")
                        .nurFont(15, weight: .bold, design: .rounded)
                        .foregroundColor(Color(hex: "1A1A2E"))
                    Spacer()
                }
                .frame(width: 242)
            }
        }
    }
}

// MARK: - Kaaba Beacon Needle & Perimeter Orb
struct KaabaBeaconNeedle: View {
    let isAligned: Bool
    
    var body: some View {
        ZStack {
            // Luminous Beacon Beam to Center
            VStack(spacing: 0) {
                // Outer Kaaba 3D Orb on Perimeter
                ZStack {
                    // Pulsing Emerald/Gold Target Ring
                    Circle()
                        .stroke(
                            isAligned ? Color(hex: "#10B981") : Color.nurGold,
                            lineWidth: isAligned ? 2.5 : 1.5
                        )
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isAligned ? Color(hex: "#10B981").opacity(0.2) : Color.white)
                        )
                        .shadow(
                            color: (isAligned ? Color(hex: "#10B981") : Color.nurGold).opacity(0.4),
                            radius: isAligned ? 10 : 5
                        )
                    
                    // Kaaba Icon
                    Image("KaabaIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                .offset(y: -10)
                
                // Emerald/Gold Gradient Pointer Line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                isAligned ? Color(hex: "#10B981") : Color.nurGold,
                                (isAligned ? Color(hex: "#10B981") : Color.nurGold).opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: isAligned ? 3.5 : 2.5, height: 100)
                
                Spacer()
            }
        }
    }
}

// MARK: - Spirit Bubble Level (Su Terazisi)
struct SpiritBubbleLevel: View {
    let pitch: Double
    let roll: Double
    let isAligned: Bool
    
    var body: some View {
        let maxOffset: CGFloat = 16.0
        let offsetX = CGFloat(max(-maxOffset, min(maxOffset, roll * 0.7)))
        let offsetY = CGFloat(max(-maxOffset, min(maxOffset, pitch * 0.7)))
        let isLevel = abs(offsetX) < 4 && abs(offsetY) < 4
        
        ZStack {
            // Level Outer Circle
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: 46, height: 46)
                .overlay(
                    Circle()
                        .stroke(
                            isLevel ? (isAligned ? Color(hex: "#10B981") : Color.nurGold) : Color(hex: "1A1A2E").opacity(0.15),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
            
            // Level Target Crosshair Center
            Circle()
                .stroke(Color.nurGold.opacity(0.4), lineWidth: 1)
                .frame(width: 16, height: 16)
            
            // Moving Spirit Bubble
            Circle()
                .fill(
                    isLevel ? (isAligned ? Color(hex: "#10B981") : Color.nurGold) : Color.orange
                )
                .frame(width: 10, height: 10)
                .offset(x: offsetX, y: offsetY)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: offsetX)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: offsetY)
        }
    }
}

// MARK: - Sacred 8-Pointed Seljuk Star Shape
struct IslamicStarRosette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let rOuter = min(rect.width, rect.height) / 2
        let rInner = rOuter * 0.65
        
        for i in 0..<16 {
            let angle = CGFloat(i) * (.pi / 8.0) - (.pi / 2.0)
            let r = (i % 2 == 0) ? rOuter : rInner
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    QiblaView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(PersistenceService.shared)
        .environmentObject(AppRouter.shared)
}
