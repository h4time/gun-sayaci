# CLAUDE PROJECT MAP - Gün Sayacı (countdown_app)

> Son güncelleme: Adım 0-10 tamamlandı (confetti, dark mode, tercihler, splash, swipe, haptic)

## Proje Özeti
Türkçe geri sayım uygulaması. Etkinlik oluştur, geri sayım takip et, bildirim al.
Package: `com.omerfarukozturk.gunsayaci` | Version: 1.0.0+6
Geliştirici: Ömer Faruk Öztürk | Website: ozelgunleriunutma.com

---

## Dosya Haritası

### lib/main.dart
Uygulama girişi. Hive + Notification init, portrait kilit, Provider(ThemeProvider) wrap, Türkçe locale, SplashScreen başlangıç.

### lib/theme/app_theme.dart ✅
Light: beyaz bg (#FFFFFF), koyu gri text (#1A1A1A), amber accent (#F5A623).
Dark: #0A0A0F bg, #1C1C1E surface, #2C2C2E card, #14FFFFFF divider, #3A3A3C switch inactive.
cardTitleStyle + cardCountdownStyle. Kategori mapping korundu.

### lib/models/event_model.dart
HiveObject veri modeli. 13 HiveField. Computed: remaining, isExpired, isToday, daysRemaining, dDayText, progress.

### lib/models/event_model.g.dart
Hive code-gen adapter.

### lib/providers/theme_provider.dart ✅ GÜNCELLENDİ
Manual light↔dark toggle (sistem takibi yok). SharedPreferences ile `isDarkMode` bool kaydı.

### lib/services/storage_service.dart
Singleton Hive CRUD.

### lib/services/notification_service.dart
Singleton. 5 kademeli hatırlatma.

### lib/screens/splash_screen.dart ✅ GÜNCELLENDİ
"#ozelgunleriunutma" accent yazı, fade-in 500ms → 1s bekle → fade-out 300ms → HomeScreen. Dark mode duyarlı.

### lib/screens/home_screen.dart ✅ (v4)
- Header: hamburger + "#ozelgunleriunutma" + "+"
- Swipe: sola kırmızı sil (iOS alert dialog onay, heavyImpact) + sağa mavi düzenle
- Boş durum: minimal calendar ikon + "Henüz etkinlik yok" + "Ekle" butonu
- BouncingScrollPhysics
- Menü: Tercihler (→PreferencesScreen), Değerlendir, Destek, Öneriler, Hakkında (Gece Modu kaldırıldı)

### lib/screens/add_event_screen.dart ✅ 2-ADIMLI WIZARD (v3)
- Adım 1: İsim + Kategori grid (2-sütun, renkli border + ✓ check)
- Adım 2: Tarih picker + Tüm Gün + Tekrarla bottom sheet + Kaydet
- Edit: Tek sayfa form + CupertinoSwitch hatırlatmalar

### lib/screens/event_detail_screen.dart ✅ GÜNCELLENDİ
- Confetti: sadece BUGÜN + sadece ilk açılışta + mediumImpact
- Paylaşım: "#ozelgunleriunutma" hashtag'li
- Butonlar: glassmorphism daire butonlar (back, edit, share)
- Haptic: lightImpact tüm butonlarda

### lib/screens/preferences_screen.dart ✅ YENİ
Tercihler sayfası (3 bölüm):
- GÖRÜNÜM: Gece Modu (CupertinoSwitch, Provider ile toggle)
- BİLDİRİMLER: Bildirim Zamanı (placeholder)
- VERİ: Yedekle/Geri Yükle (placeholder), Tüm Verileri Sil (kırmızı, onay dialog)

### lib/screens/about_screen.dart ✅
Hakkında sayfası.

### lib/screens/support_screen.dart ✅
Destek sayfası.

### lib/screens/suggestions_screen.dart ✅
Öneriler sayfası.

### lib/widgets/countdown_card.dart ✅ (v6)
- 365-gün progress ring (0→hedef 800ms animasyon)
- Kategori badge %70 opacity, 10px font
- Tarih 12px, %65 opacity
- Press: scale 0.97 + shadow boost + accent border
- BUGÜN badge üst ortada

### lib/widgets/confetti_widget.dart ✅ GÜNCELLENDİ
Gold/amber palette (6 ton), 35 parçacık, 1.5s tek sefer (repeat yok), fade-out son %30.

---

## State Management
- **Tema:** Provider (ThemeProvider → manual light/dark toggle → SharedPreferences)
- **Etkinlikler:** Hive Box doğrudan dinleme (ValueListenableBuilder)
- **Bildirimler:** Singleton servis

## Routing
```
SplashScreen (#ozelgunleriunutma fade) → HomeScreen
  ├→ EventDetailScreen (push)
  ├→ AddEventSheet wizard (push, 2 adım)
  ├→ CategorySheet (showModalBottomSheet)
  └→ SettingsPage (push, slide-in)
       ├→ PreferencesScreen (push) — YENİ
       ├→ AboutScreen (push)
       ├→ SupportScreen (push)
       ├→ SuggestionsScreen (push)
       └→ Rate App (url_launcher)
```

## Kullanılan Paketler
| Paket | Versiyon | Amaç |
|-------|----------|------|
| hive / hive_flutter | 2.2.3 / 1.1.0 | Yerel NoSQL veritabanı |
| provider | 6.1.2 | Tema state management |
| google_fonts | 6.2.1 | Poppins + DM Serif Display |
| flutter_local_notifications | 18.0.1 | Zamanlanmış bildirimler |
| timezone | 0.10.0 | Saat dilimi |
| intl | 0.20.2 | Türkçe tarih formatlama |
| flutter_animate | 4.5.2 | Animasyonlar |
| uuid | 4.5.1 | Benzersiz ID |
| share_plus | 10.1.4 | Paylaşım |
| shared_preferences | 2.3.4 | Tema + tercih kaydı |
| cupertino_icons | 1.0.8 | iOS ikonları |
| url_launcher | 6.3.1 | URL açma |
| hive_generator | 2.0.1 | Hive code-gen |

## Tamamlanan Tüm Adımlar
- [x] Proje haritası + Tasarım rehberi
- [x] Ana ekran (Days tarzı header, floating toggle, kartlar)
- [x] Haptic feedback (tüm etkileşimlerde)
- [x] Hamburger menü + Ayarlar sayfaları
- [x] 2-adımlı wizard etkinlik ekleme
- [x] Renkli kategori badge kartlar + 365-gün progress
- [x] Adım 0: Kart ince ayarlar (press efekti, tarih/badge küçültme)
- [x] Adım 1: Swipe aksiyonları (sil onay + düzenle)
- [x] Adım 2: Gelişmiş boş durum
- [x] Adım 3: Confetti (gold/amber, 1.5s, ilk açılış)
- [x] Adım 4: Haptic haritası (detaylı)
- [x] Adım 5: Paylaşım (#ozelgunleriunutma)
- [x] Adım 6: Micro-interactions (spring press, BouncingScrollPhysics)
- [x] Adım 7: Kategori label düzeltmesi
- [x] Adım 8: Menü yeniden düzenleme (Gece Modu → Tercihler)
- [x] Adım 9: Dark mode (manual toggle, #0A0A0F bg)
- [x] Adım 10: Splash (#ozelgunleriunutma), scroll physics
