import SwiftUI

// MARK: - 1080x1920 High-Res Story Canvas
public struct SpiritualStoryShareCanvas: View {
    public let message: SpiritualMessage
    public let theme: StoryTheme
    public let language: LanguageCode
    
    public init(message: SpiritualMessage, theme: StoryTheme = .midnight, language: LanguageCode = .tr) {
        self.message = message
        self.theme = theme
        self.language = language
    }
    
    public var body: some View {
        ZStack {
            // ── 1. BACKGROUND GRADIENT ──
            LinearGradient(
                colors: theme.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // ── 2. DECORATIVE AMBIENT AURA & GLOW ORBS ──
            if theme == .emerald {
                Circle()
                    .fill(Color(hex: "#00E676").opacity(0.12))
                    .frame(width: 1100, height: 1100)
                    .offset(x: -250, y: -650)
                    .blur(radius: 150)
                
                Circle()
                    .fill(Color(hex: "#D4AF37").opacity(0.15))
                    .frame(width: 900, height: 900)
                    .offset(x: 350, y: 650)
                    .blur(radius: 130)
            } else if theme == .ivory {
                Circle()
                    .fill(Color(hex: "#D4AF37").opacity(0.14))
                    .frame(width: 1000, height: 1000)
                    .offset(x: -200, y: -600)
                    .blur(radius: 140)
                
                Circle()
                    .fill(Color(hex: "#E5C158").opacity(0.12))
                    .frame(width: 900, height: 900)
                    .offset(x: 300, y: 600)
                    .blur(radius: 130)
            } else { // Midnight & Kaaba Noir
                Circle()
                    .fill(Color(hex: "#D4AF37").opacity(0.18))
                    .frame(width: 1200, height: 1200)
                    .offset(x: -300, y: -700)
                    .blur(radius: 150)
                
                Circle()
                    .fill(Color(hex: "#5D3FD3").opacity(0.12))
                    .frame(width: 1000, height: 1000)
                    .offset(x: 400, y: 700)
                    .blur(radius: 130)
            }
            
            // ── 3. SACRED ROSETTE WATERMARK ──
            Image(systemName: "seal.fill")
                .font(.system(size: 850))
                .foregroundColor(theme.goldAccent.opacity(theme.isLight ? 0.04 : 0.03))
                .rotationEffect(.degrees(15))
                .offset(x: 220, y: 150)
            
            // ── 4. OUTER CORNER ORNAMENTS & BORDER ──
            RoundedRectangle(cornerRadius: 48)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.goldAccent.opacity(0.6),
                            theme.goldAccent.opacity(0.1),
                            theme.goldAccent.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .padding(40)
            
            VStack(spacing: 0) {
                // ── 5. BRAND HEADER: LOGO & APP NAME ──
                VStack(spacing: 16) {
                    ZStack {
                        // Outer Golden Halo
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FFE58F"),
                                        Color(hex: "#D4AF37"),
                                        Color(hex: "#8A6414")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 130, height: 130)
                            .shadow(color: theme.goldAccent.opacity(0.5), radius: 25)
                        
                        // Real App Logo if present, otherwise luxury icon emblem
                        if let logoImage = UIImage(named: "LaunchLogo") ?? UIImage(named: "1024") {
                            Image(uiImage: logoImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(theme.isLight ? .white : Color(hex: "#0E1626"))
                        }
                    }
                    
                    Text("NurVakti")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .tracking(6)
                        .foregroundStyle(
                            LinearGradient(
                                colors: theme.isLight
                                    ? [Color(hex: "#8A6414"), Color(hex: "#C9A84C")]
                                    : [Color(hex: "#FFF4D0"), Color(hex: "#D4AF37")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: theme.goldAccent.opacity(0.3), radius: 12, y: 3)
                }
                .padding(.top, 140)
                
                Spacer()
                
                // ── 6. MAIN CONTENT CARD ──
                ZStack {
                    // Glass Canvas
                    RoundedRectangle(cornerRadius: 48)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 48)
                                .stroke(theme.cardBorder, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(theme.isLight ? 0.08 : 0.4), radius: 36, y: 16)
                    
                    VStack(spacing: 32) {
                        // ── CELEBRATION OCCASION HEADER ──
                        let celebration = celebrationHeadline(for: message, language: language)
                        
                        VStack(spacing: 12) {
                            // Grand Headline Badge with Golden Aura
                            HStack(spacing: 14) {
                                Image(systemName: celebration.icon)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(theme.goldAccent)
                                
                                Text(celebration.headline)
                                    .font(.system(size: celebration.headline.count > 26 ? 28 : (celebration.headline.count > 18 ? 32 : 36), weight: .heavy, design: .serif))
                                    .tracking(2.5)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: theme.isLight
                                                ? [Color(hex: "#8A6414"), Color(hex: "#C9A84C")]
                                                : [Color(hex: "#FFF4D0"), Color(hex: "#D4AF37"), Color(hex: "#FFE58F")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: theme.goldAccent.opacity(0.35), radius: 8, y: 2)
                                    .multilineTextAlignment(.center)
                                
                                Image(systemName: celebration.icon)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(theme.goldAccent)
                            }
                            
                            // Sub-topic pill (e.g. "Gönül Duası", "Cuma'nın Bereketi", etc.)
                            if let sub = celebration.subBadge, !sub.isEmpty {
                                Text(sub.uppercased())
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.goldAccent.opacity(0.95))
                                    .tracking(3)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(theme.goldAccent.opacity(0.12))
                                            .overlay(
                                                Capsule().stroke(theme.goldAccent.opacity(0.35), lineWidth: 1.2)
                                            )
                                    )
                            }
                        }
                        .padding(.top, 4)
                        
                        // Arabic Text (if present)
                        if let arabic = message.arabicText, !arabic.isEmpty {
                            Text(arabic)
                                .font(.custom("KFGQPCUthmanicScriptHAFS", size: dynamicArabicSize(arabic)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(theme.isLight ? Color(hex: "#2C1E11") : .white)
                                .lineSpacing(18)
                                .padding(.horizontal, 36)
                                .environment(\.layoutDirection, .rightToLeft)
                                .shadow(color: theme.goldAccent.opacity(0.25), radius: 10)
                        }
                        
                        // Golden Ornamental Divider
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill(LinearGradient(colors: [.clear, theme.goldAccent], startPoint: .leading, endPoint: .trailing))
                                .frame(height: 2)
                            
                            Image(systemName: "rhombus.fill")
                                .font(.system(size: 20))
                                .foregroundColor(theme.goldAccent)
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [theme.goldAccent, .clear], startPoint: .leading, endPoint: .trailing))
                                .frame(height: 2)
                        }
                        .frame(maxWidth: 420)
                        
                        // Main Message Text
                        Text(message.text)
                            .font(.system(size: dynamicTextSize(message.text), weight: .medium, design: .serif))
                            .foregroundColor(theme.primaryTextColor.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .lineSpacing(16)
                            .padding(.horizontal, 40)
                        
                        // Author / Source Badge
                        if let source = message.authorOrSource, !source.isEmpty {
                            Text(source)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(theme.goldAccent)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(theme.goldAccent.opacity(0.12))
                                        .overlay(
                                            Capsule().stroke(theme.goldAccent.opacity(0.35), lineWidth: 1.5)
                                        )
                                    )
                        }
                    }
                    .padding(50)
                }
                .padding(.horizontal, 56)
                .frame(maxHeight: 1180)
                
                Spacer()
                
                // ── 7. FOOTER: APP BADGES & SLOGAN ──
                VStack(spacing: 20) {
                    Text(LocalizationManager.shared.localizedString("share.journeyStart"))
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(theme.secondaryTextColor)
                    
                    HStack(spacing: 24) {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.logo")
                            Text("App Store")
                        }
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(theme.isLight ? Color.black.opacity(0.06) : Color.white.opacity(0.08))
                                .overlay(
                                    Capsule().stroke(theme.isLight ? Color.black.opacity(0.12) : Color.white.opacity(0.2), lineWidth: 1.5)
                                )
                        )
                        
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Google Play")
                        }
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(theme.isLight ? Color.black.opacity(0.06) : Color.white.opacity(0.08))
                                .overlay(
                                    Capsule().stroke(theme.isLight ? Color.black.opacity(0.12) : Color.white.opacity(0.2), lineWidth: 1.5)
                                )
                        )
                    }
                }
                .padding(.bottom, 110)
            }
        }
        .frame(width: 1080, height: 1920)
    }
    
    // MARK: - Grand Celebration Headline Resolver
    private func celebrationHeadline(for message: SpiritualMessage, language: LanguageCode) -> (headline: String, subBadge: String?, icon: String) {
        switch message.category {
        case .friday:
            let headline: String = {
                switch language {
                case .tr: return "HAYIRLI CUMALAR"
                case .en: return "BLESSED FRIDAY"
                case .ar: return "جمعة مباركة"
                case .de: return "GESEGNETEN FREITAG"
                case .pt: return "SEXTA-FEIRA ABENÇOADA"
                }
            }()
            let sub = message.title != "Hayırlı Cumalar" && !message.title.isEmpty ? message.title : nil
            return (headline, sub, "moon.stars.fill")
            
        case .kandil:
            let subCat = message.subCategory?.lowercased() ?? ""
            let titleLower = message.title.lowercased()
            
            let headline: String = {
                if subCat == "mevlid" || titleLower.contains("mevlid") {
                    return language == .tr ? "MEVLİD KANDİLİNİZ MÜBAREK OLSUN" : "MEVLID KANDIL MUBARAK"
                } else if subCat == "regaip" || titleLower.contains("regaip") {
                    return language == .tr ? "REGAİP KANDİLİNİZ MÜBAREK OLSUN" : "REGAIP KANDIL MUBARAK"
                } else if subCat == "mirac" || titleLower.contains("miraç") || titleLower.contains("mirac") {
                    return language == .tr ? "MİRAÇ KANDİLİNİZ MÜBAREK OLSUN" : "MIRAJ KANDIL MUBARAK"
                } else if subCat == "berat" || titleLower.contains("berat") {
                    return language == .tr ? "BERAT KANDİLİNİZ MÜBAREK OLSUN" : "BERAT KANDIL MUBARAK"
                } else if subCat == "kadir" || titleLower.contains("kadir") {
                    return language == .tr ? "KADİR GECENİZ MÜBAREK OLSUN" : "LAYLAT AL-QADR MUBARAK"
                } else {
                    return language == .tr ? "KANDİLİNİZ MÜBAREK OLSUN" : "BLESSED KANDIL NIGHT"
                }
            }()
            let sub = (message.title != headline && !headline.contains(message.title.uppercased())) ? message.title : nil
            return (headline, sub, "moon.stars.fill")
            
        case .bayram:
            let subCat = message.subCategory?.lowercased() ?? ""
            let titleLower = message.title.lowercased()
            
            let headline: String = {
                if subCat == "ramadan" || titleLower.contains("ramazan") {
                    return language == .tr ? "RAMAZAN BAYRAMINIZ MÜBAREK OLSUN" : "EID AL-FITR MUBARAK"
                } else if subCat == "eidaladha" || titleLower.contains("kurban") {
                    return language == .tr ? "KURBAN BAYRAMINIZ MÜBAREK OLSUN" : "EID AL-ADHA MUBARAK"
                } else if subCat == "arafah" || titleLower.contains("arefe") {
                    return language == .tr ? "AREFE GÜNÜNÜZ MÜBAREK OLSUN" : "BLESSED DAY OF ARAFAH"
                } else {
                    return language == .tr ? "BAYRAMINIZ MÜBAREK OLSUN" : "EID MUBARAK"
                }
            }()
            let sub = (message.title != headline && !headline.contains(message.title.uppercased())) ? message.title : nil
            return (headline, sub, "sparkles")
            
        case .specialDays:
            let subCat = message.subCategory?.lowercased() ?? ""
            let titleLower = message.title.lowercased()
            
            let headline: String = {
                if subCat == "threemonths" || titleLower.contains("üç aylar") {
                    return language == .tr ? "ÜÇ AYLARINIZ MÜBAREK OLSUN" : "BLESSED THREE MONTHS"
                } else if subCat == "hijrinewyear" || titleLower.contains("hicri") {
                    return language == .tr ? "HİCRİ YILBAŞINIZ MÜBAREK OLSUN" : "HIJRI NEW YEAR MUBARAK"
                } else if subCat == "ashura" || titleLower.contains("aşure") {
                    return language == .tr ? "AŞURE GÜNÜNÜZ MÜBAREK OLSUN" : "BLESSED DAY OF ASHURA"
                } else {
                    return language == .tr ? "MÜBAREK GÜNLER" : "BLESSED DAYS"
                }
            }()
            let sub = (message.title != headline && !headline.contains(message.title.uppercased())) ? message.title : nil
            return (headline, sub, "star.fill")
            
        case .dailyWisdom:
            if message.title.contains("AYET") || message.title.contains("HADİS") || message.title.contains("DUA") {
                return (message.title.uppercased(), nil, "sparkles")
            }
            let headline = language == .tr ? "GÜNÜN HİKMETLİ SÖZÜ" : "DAILY WISDOM"
            let sub = (message.title != headline && message.title != "Günün Sözü") ? message.title : nil
            return (headline, sub, "quote.bubble.fill")
            
        default:
            return (message.title.uppercased(), nil, "sparkles")
        }
    }
    
    private func dynamicTextSize(_ text: String) -> CGFloat {
        let length = text.count
        if length > 250 { return 36 }
        if length > 160 { return 40 }
        if length > 90 { return 44 }
        return 48
    }
    
    private func dynamicArabicSize(_ text: String) -> CGFloat {
        let length = text.count
        if length > 150 { return 46 }
        if length > 80 { return 54 }
        return 62
    }
}
