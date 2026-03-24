import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Isha Theme Background
            LinearGradient(colors: [Color.nurMidTop, Color.nurMidBot], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            StarFieldView(opacity: 0.6) // Reusable component
            
            VStack(spacing: 30) {
                // Logo placeholder (Apple icon)
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [.nurGold.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 100))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.nurGold)
                        .shadow(color: .nurGold.opacity(0.5), radius: 10)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                VStack(spacing: 12) {
                    Text("NurVakti")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("بِسْمِ اللهِ الرَّحْمٰنِ الرَّحيمِ")
                        .font(.custom("Traditional Arabic", size: 28))
                        .foregroundColor(.nurGold)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                scale = 1.05
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(1.0)) {
                scale = 1.0
            }
            
            // Auto finish after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                onFinish()
            }
        }
    }
}

#Preview {
    SplashView {}
}
