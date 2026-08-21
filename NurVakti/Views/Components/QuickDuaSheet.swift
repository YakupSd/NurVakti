import SwiftUI

struct QuickDuaSheet: View {
    let item: DuaLibraryItem
    @EnvironmentObject var library: DuaLibraryService
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    var isPlaying: Bool { audio.isPlaying }
    
    var body: some View {
        ZStack {
            // Background — Warm Cream Light Luxury
            Color(hex: "F8F6F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Grabber & Controls Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "1A1A2E").opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        library.toggleFavourite(item)
                        HapticManager.shared.selectionChanged()
                    }) {
                        Image(systemName: item.isFavourite ? "star.fill" : "star")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(item.isFavourite ? .nurGold : Color(hex: "1A1A2E").opacity(0.4))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "1A1A2E").opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // ── Header Title & Category ────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            if let cat = item.dua.libraryCategory {
                                HStack(spacing: 6) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 11, weight: .bold))
                                    Text(cat.localizedName(for: loc.currentLanguage).uppercased())
                                        .nurFont(11, weight: .bold)
                                        .kerning(1.2)
                                }
                                .foregroundColor(cat.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(cat.accentColor.opacity(0.12))
                                .cornerRadius(8)
                            }
                            
                            Text(item.dua.title(for: loc.currentLanguage))
                                .nurFont(24, weight: .bold)
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        // ── Arabic Card ────────────────
                        VStack(spacing: 12) {
                            Text(item.dua.arabicText)
                                .font(.custom("ScheherazadeNew-Bold", size: 30))
                                .lineSpacing(14)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(hex: "2C1E11"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .environment(\.layoutDirection, .rightToLeft)
                        }
                        .padding(22)
                        .background(Color.white)
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.nurGold.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, 20)
                        
                        // ── Okunuş (Transliteration) ────────────
                        if !item.dua.transliteration.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(loc.localizedString("dua.transliteration"))
                                    .nurFont(11, weight: .bold)
                                    .kerning(1.1)
                                    .foregroundColor(.nurGold)
                                
                                Text(item.dua.transliteration)
                                    .nurFont(15, weight: .medium, design: .serif)
                                    .italic()
                                    .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                                    .lineSpacing(6)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // ── Anlam (Meaning) ────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localizedString("general.meaning"))
                                .nurFont(11, weight: .bold)
                                .kerning(1.1)
                                .foregroundColor(.nurGold)
                            
                            Text(item.dua.meaning(for: loc.currentLanguage))
                                .nurFont(15)
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.85))
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "1A1A2E").opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bottom space for floating controls
                        Color.clear.frame(height: 90)
                    }
                    .padding(.top, 4)
                }
            }
            
            // ── Floating Action Bar (Apple VIP) ──────
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // Play Audio Button
                    Button(action: {
                        audio.playPrayerDua(item.dua)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(isPlaying 
                                 ? loc.localizedString("audio.pause") 
                                 : loc.localizedString("audio.listen"))
                                .nurFont(14, weight: .bold)
                        }
                        .foregroundColor(Color(hex: "1A1A2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#D4AF37"), Color(hex: "#C9A84C")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.nurGold.opacity(0.35), radius: 10, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    // Mark as Read Button
                    Button(action: {
                        library.markAsRead(item)
                        HapticManager.shared.success()
                        dismiss()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(item.userState.isReadToday ? Color.green : Color.white)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(item.userState.isReadToday ? Color.green : Color(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(item.userState.isReadToday ? .white : Color(hex: "1A1A2E"))
                        }
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "F8F6F0").opacity(0), Color(hex: "F8F6F0").opacity(0.95), Color(hex: "F8F6F0")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}
