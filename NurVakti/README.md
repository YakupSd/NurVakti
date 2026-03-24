# NurVakti - Akıllı Namaz Vakti Uygulaması

NurVakti, modern ve şık arayüzü ile namaz vakitlerini takip etmenizi sağlayan, tamamen Swift ile geliştirilmiş bir iOS uygulamasıdır.

## Önemli Özellikler & Geliştirmeler

### 1. 7 Vakit Yapısı (Restored)
Uygulama, kullanıcının talebi üzerine geleneksel 6 vakit yerine **7 vakit** düzenine geçirilmiştir:
- **İmsak**
- **Sabah** (Fajr) - *Yeni eklendi*
- **Güneş**
- **Öğle**
- **İkindi**
- **Akşam**
- **Yatsı**

### 2. Aladhan API Entegrasyonu (Diyanet Metodu)
Yerel astronomik hesaplamalardaki (zaman dilimi, boylam kayması vb.) hataları gidermek için sistem bütünüyle **Aladhan API**'ye taşınmıştır:
- **Global Doğruluk**: Giresun'dan Almanya'ya kadar dünyanın her yerinde resmi Diyanet (Method 13) vakitlerini çeker.
- **Otomatik Konum**: Kullanıcının koordinatlarına göre en yakın resmi vakitleri anında getirir.
- **Async/Await Mimarisi**: Vakitler modern Swift `async/await` yapısı ile arka planda performanslı bir şekilde güncellenir.

### 3. Akıllı Önbellek & Bildirimler
- **30 Günlük Hafıza**: Konum güncellendiğinde 30 günlük vakitler tek seferde çekilir ve çevrimdışı kullanım için saklanır.
- **Hassas Bildirimler**: Her vakit için ayrı ayrı bildirim ve ezan sesi desteği mevcuttur.

## Teknik Mimari
- **UI**: SwiftUI (Modern, dinamik gradyanlı ve temalı arayüz)
- **State Management**: ObservableObject & Combine
- **Network**: URLSession (Aladhan API)
- **Local Persistence**: PersistenceService (Cache & Settings)

---
*Geliştirici: NurVakti Team*
