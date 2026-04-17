import Foundation
import SwiftUI
import Combine

@MainActor
final class DuaLibraryService: ObservableObject {
    static let shared = DuaLibraryService()
    
    // All duas (static catalogue from PrayerGuideData + dynamic monthly)
    @Published var allDuas: [DuaLibraryItem] = []
    
    // User's favourites (ordered)
    @Published var favourites: [DuaLibraryItem] = []
    
    // Morning / Evening routine
    @Published var morningRoutine: [DuaLibraryItem] = []
    @Published var eveningRoutine: [DuaLibraryItem] = []
    
    // Today's read status
    @Published var morningCompletedCount: Int = 0
    @Published var eveningCompletedCount: Int = 0
    
    private let stateKey = "dua_user_states"
    
    // ── Setup ──────────────────────────────
    func setup() {
        loadCatalogue()      // merge static + monthly duas
        loadUserStates()     // load favourites & routine from UserDefaults
        resetDailyIfNeeded() // reset isReadToday at midnight
    }
    
    private func loadCatalogue() {
        // Static duas from PrayerGuideData.swift
        let staticDuas = PrayerGuideData.allDuas
        
        let states = loadStatesFromDefaults()
        allDuas = staticDuas.map { dua in
            let state = states[dua.id] ?? DuaUserState(id: dua.id)
            return DuaLibraryItem(dua: dua, userState: state)
        }
        rebuildDerivedLists()
    }
    
    private func loadUserStates() {
        let states = loadStatesFromDefaults()
        for idx in allDuas.indices {
            if let state = states[allDuas[idx].id] {
                allDuas[idx].userState = state
            }
        }
        rebuildDerivedLists()
    }
    
    private func rebuildDerivedLists() {
        favourites = allDuas
            .filter { $0.isFavourite }
            .sorted { $0.userState.routineOrder < $1.userState.routineOrder }
        
        morningRoutine = allDuas
            .filter { $0.userState.routineSlot == .morning || 
                      $0.userState.routineSlot == .both }
            .sorted { $0.userState.routineOrder < $1.userState.routineOrder }
        
        eveningRoutine = allDuas
            .filter { $0.userState.routineSlot == .evening || 
                      $0.userState.routineSlot == .both }
            .sorted { $0.userState.routineOrder < $1.userState.routineOrder }
        
        morningCompletedCount = morningRoutine.filter { 
            $0.userState.isReadToday 
        }.count
        eveningCompletedCount = eveningRoutine.filter { 
            $0.userState.isReadToday 
        }.count
    }
    
    // ── User Actions ────────────────────────
    func toggleFavourite(_ item: DuaLibraryItem) {
        guard let idx = allDuas.firstIndex(where: { $0.id == item.id }) 
        else { return }
        allDuas[idx].userState.isFavourite.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        saveStates()
        rebuildDerivedLists()
    }
    
    func setRoutineSlot(_ slot: RoutineSlot, for item: DuaLibraryItem) {
        guard let idx = allDuas.firstIndex(where: { $0.id == item.id }) 
        else { return }
        allDuas[idx].userState.routineSlot = slot
        
        // Auto-assign order at end of current routine
        if slot != .none {
            let maxOrder = allDuas
                .filter { $0.userState.routineSlot != .none }
                .map { $0.userState.routineOrder }
                .max() ?? 0
            allDuas[idx].userState.routineOrder = maxOrder + 1
        }
        saveStates()
        rebuildDerivedLists()
    }
    
    func markAsRead(_ item: DuaLibraryItem) {
        guard let idx = allDuas.firstIndex(where: { $0.id == item.id }) 
        else { return }
        allDuas[idx].userState.isReadToday = true
        allDuas[idx].userState.lastReadDate = Date()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        saveStates()
        rebuildDerivedLists()
    }
    
    func reorderRoutine(slot: RoutineSlot, from: IndexSet, to: Int) {
        // Handle drag-to-reorder in routine list
        var list = slot == .morning ? morningRoutine : eveningRoutine
        list.move(fromOffsets: from, toOffset: to)
        for (i, item) in list.enumerated() {
            if let idx = allDuas.firstIndex(where: { $0.id == item.id }) {
                allDuas[idx].userState.routineOrder = i
            }
        }
        saveStates()
        rebuildDerivedLists()
    }
    
    // ── Daily Reset ─────────────────────────
    private func resetDailyIfNeeded() {
        let key = "last_dua_reset_date"
        let lastReset = UserDefaults.standard.object(forKey: key) as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        guard lastReset == nil || lastReset! < today else { 
            // Check if items need reset based on date logic
            return 
        }
        
        // Reset all isReadToday flags
        for idx in allDuas.indices {
            allDuas[idx].userState.isReadToday = false
        }
        UserDefaults.standard.set(today, forKey: key)
        saveStates()
        rebuildDerivedLists()
    }
    
    // ── Persistence ─────────────────────────
    private func saveStates() {
        let states = Dictionary(uniqueKeysWithValues: 
            allDuas.map { ($0.id, $0.userState) })
        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: stateKey)
        }
    }
    
    private func loadStatesFromDefaults() -> [String: DuaUserState] {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let dict = try? JSONDecoder().decode(
                  [String: DuaUserState].self, from: data)
        else { return [:] }
        return dict
    }
    
    // ── Search ──────────────────────────────
    func search(_ query: String, 
                category: LibraryCategory? = nil) -> [DuaLibraryItem] {
        var results = allDuas
        if let cat = category {
            results = results.filter { $0.dua.libraryCategory == cat }
        }
        guard !query.isEmpty else { return results }
        let q = query.lowercased()
        return results.filter {
            $0.dua.title(for: .tr).lowercased().contains(q) ||
            $0.dua.arabicText.contains(q) ||
            $0.dua.meaning(for: .tr).lowercased().contains(q)
        }
    }
}
