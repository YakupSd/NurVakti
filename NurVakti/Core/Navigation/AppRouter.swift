import SwiftUI
import UIKit
import Combine

// MARK: - App Destinations
enum AppDestination: Hashable {
    case home
    case quran
    case tasbih
    case zakat
    case calendar
    case qibla
    case dhikr
    case settings
    case addDhikr
    case hatim(page: Int, vm: QuranViewModel)
    case duaDetail(dua: DuaItem)
    case mushaf(surah: SurahInfo? = nil, page: Int? = nil)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home: hasher.combine(0)
        case .quran: hasher.combine(1)
        case .tasbih: hasher.combine(2)
        case .zakat: hasher.combine(3)
        case .calendar: hasher.combine(4)
        case .qibla: hasher.combine(5)
        case .dhikr: hasher.combine(6)
        case .settings: hasher.combine(7)
        case .addDhikr: hasher.combine(8)
        case .hatim(let page, _): hasher.combine(9); hasher.combine(page)
        case .duaDetail(let dua): hasher.combine(10); hasher.combine(dua.id)
        case .mushaf(let surah, let page): 
            hasher.combine(11)
            hasher.combine(surah?.id)
            hasher.combine(page)
        }
    }
    
    static func == (lhs: AppDestination, rhs: AppDestination) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home), (.quran, .quran), (.tasbih, .tasbih), (.zakat, .zakat), (.calendar, .calendar), (.qibla, .qibla), (.dhikr, .dhikr), (.settings, .settings), (.addDhikr, .addDhikr):
            return true
        case (.hatim(let lPage, _), .hatim(let rPage, _)):
            return lPage == rPage
        case (.duaDetail(let lDua), .duaDetail(let rDua)):
            return lDua.id == rDua.id
        case (.mushaf(let lSurah, let lPage), .mushaf(let rSurah, let rPage)):
            return lSurah?.id == rSurah?.id && lPage == rPage
        default:
            return false
        }
    }
}

// MARK: - Router Protocol
protocol Router: ObservableObject {
    var nav: UINavigationController? { get set }
    func push(to destination: AppDestination)
    func pushTo(view: UIViewController)
    func pop()
    func popToRoot()
}

// MARK: - App Router
final class AppRouter: ObservableObject, Router {
    @Published var nav: UINavigationController?
    
    static let shared = AppRouter()
    private init() {}
    
    func push(to destination: AppDestination) {
        guard let nav = nav else { return }
        let view = destination.view
        let vc = CustomHostingController(rootView: view, 
                                        navigationBarTitle: destination.title, 
                                        navigationBarHidden: destination.isNavBarHidden,
                                        rightImage: destination.rightImage,
                                        rightButtonAction: destination.rightButtonAction)
        
        // Premium Transition Animation (matching example)
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromRight
        nav.view.layer.add(transition, forKey: kCATransition)
        
        nav.pushViewController(vc, animated: false)
    }
    
    func pushTo(view: UIViewController) {
        guard let nav = nav else { return }
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromRight
        nav.view.layer.add(transition, forKey: kCATransition)
        
        nav.pushViewController(view, animated: false)
    }
    
    func pop() {
        nav?.popViewController(animated: true)
    }
    
    func popToRoot() {
        nav?.popToRootViewController(animated: true)
    }
    
    func presentSheet<V: View>(view: V) {
        let vc = UIHostingController(rootView: view.environmentObject(self))
        vc.modalPresentationStyle = .pageSheet
        nav?.present(vc, animated: true)
    }
}

// MARK: - AppDestination View Extension
extension AppDestination {
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomeView(vm: HomeViewModel())
        case .quran: QuranView()
        case .tasbih: TasbihModeView()
        case .zakat: ZakatCalculatorView()
        case .calendar: IslamicCalendarView()
        case .qibla: QiblaView()
        case .dhikr: DhikrView(vm: DhikrViewModel())
        case .settings: SettingsView(vm: SettingsViewModel())
        case .addDhikr: AddDhikrView(vm: DhikrViewModel())
        case .hatim(let page, _): MushafMainView(page: page)
        case .duaDetail(let dua): DuaDetailView(dua: dua, language: LocalizationManager.shared.currentLanguage)
        case .mushaf(let surah, let page):
            if let surah = surah {
                MushafMainView(surah: surah)
            } else {
                MushafMainView(page: page ?? 1)
            }
        }
    }
    
    var title: String {
        switch self {
        case .home: return ""
        case .quran: return LocalizationManager.shared.localizedString("menu_quran")
        case .tasbih: return "Tasbihat"
        case .zakat: return LocalizationManager.shared.localizedString("home.zakatCalculator")
        case .calendar: return LocalizationManager.shared.localizedString("home.calendar")
        case .qibla: return LocalizationManager.shared.localizedString("home.qiblaShortcut")
        case .dhikr: return LocalizationManager.shared.localizedString("menu_dhikr")
        case .settings: return LocalizationManager.shared.localizedString("settings.title")
        case .addDhikr: return LocalizationManager.shared.localizedString("dhikr.addNew")
        case .hatim: return "Hatim"
        case .duaDetail(let dua): return "Dua"
        case .mushaf(let surah, _): return surah?.englishName ?? "Mushaf"
        }
    }
    
    var isNavBarHidden: Bool {
        switch self {
        case .home: return true
        case .mushaf: return false
        default: return false
        }
    }
    
    var rightImage: String? {
        switch self {
        case .duaDetail: return "square.and.arrow.up"
        default: return nil
        }
    }
    
    var rightButtonAction: (() -> Void)? {
        switch self {
        case .duaDetail(let dua):
            return {
                let text = "\(dua.arabicText)\n\n\(dua.translation[.tr] ?? "")"
                let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                AppRouter.shared.nav?.present(vc, animated: true)
            }
        default:
            return nil
        }
    }
}
