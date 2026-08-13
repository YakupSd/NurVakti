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
            Color.nurDarkBlue.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // ── Header Title (Responsive) ────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            if let cat = item.dua.libraryCategory {
                                Label(cat.localizedName(for: loc.currentLanguage), 
                                      systemImage: cat.icon)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(cat.accentColor)
                                    .textCase(.uppercase)
                                    .tracking(1.5)
                            }
                            Text(item.dua.title(for: loc.currentLanguage))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 40) // More space for floating buttons

                        // ── Arabic Text ────────────────
                        Text(item.dua.arabicText)
                            .font(.custom("Amiri-Bold", size: 32))
                            .lineSpacing(12)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color(hex: "1A1A2E"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .environment(\.layoutDirection, .rightToLeft)
                            .shadow(color: .nurGold.opacity(0.1), radius: 10)
                        
                        // ── Transliteration ────────────
                        VStack(alignment: .leading, spacing: 6) {
                            Text(loc.localizedString("dua.transliteration"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.nurGold.opacity(0.8))
                                .textCase(.uppercase)
                            Text(item.dua.transliteration)
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .italic()
                                .foregroundColor(Color(hex: "1A1A2E").opacity(0.8))
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        // ── Meaning ────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text(loc.localizedString("dua.meaning"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.nurGold.opacity(0.8))
                                .textCase(.uppercase)
                            Text(item.dua.meaning(for: loc.currentLanguage))
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "1A1A2E"))
                                .lineSpacing(8)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(ColorColor(hex: "1A1A2E").opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 160) // Extra room for floating buttons
                }
            }
            
            // ── Floating Audio Control (Refined) ──────
            VStack {
                Spacer()
                
                // Bottom Gradient Shade for better text visibility
                LinearGradient(colors: [.clear, .nurDarkBlue.opacity(0.95)], 
                               startPoint: .top, 
                               endPoint: .bottom)
                    .frame(height: 140)
                    .allowsHitTesting(false)
                    .overlay(
                        HStack(spacing: 15) {
                            Button {
                                audio.playPrayerDua(item.dua)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(ColorColor(hex: "1A1A2E").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .foregroundColor(Color(hex: "1A1A2E"))
                                    }
                                    Text(isPlaying 
                                        ? loc.localizedString("audio.pause") 
                                        : loc.localizedString("audio.listen"))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hex: "1A1A2E"))
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 24)
                                .padding(.vertical, 8)
                                .background(Color.nurGold)
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
                            }
                            
                            Button {
                                library.markAsRead(item)
                                HapticManager.shared.success()
                                dismiss()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(item.userState.isReadToday ? Color.green : ColorColor(hex: "1A1A2E").opacity(0.12))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(hex: "1A1A2E"))
                                }
                                .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
                            }
                        }
                        .padding(.bottom, 40)
                    )
            }
            .ignoresSafeArea()
            
            // Top Close & Favourite Buttons (Floating)
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A2E").opacity(0.5))
                            .padding(12)
                            .background(Color(hex: "1A1A2E").opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        library.toggleFavourite(item)
                        HapticManager.shared.selectionChanged()
                    } label: {
                        Image(systemName: item.isFavourite ? "star.fill" : "star")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(item.isFavourite ? .nurGold : Color(hex: "1A1A2E").opacity(0.3))
                            .padding(12)
                            .background(Color(hex: "1A1A2E").opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(20)
                Spacer()
            }
        }
    }
}
