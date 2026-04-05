# DESIGN SYSTEM - Gün Sayacı

> Referans: "Days - Countdown & Widgets" iOS uygulaması
> Felsefe: Minimal, fotoğraf odaklı, premium, sade

---

## Renk Paleti

### Light Theme
| Rol | Renk | Kod |
|-----|------|-----|
| Background | Saf beyaz | `#FFFFFF` |
| Settings background | Krem/bej | `#F5F5F0` |
| Card overlay (alt %55) | Transparent -> siyah | `transparent -> rgba(0,0,0,0.55)` |
| Primary text | Koyu gri | `#1A1A1A` |
| Secondary text | Orta gri | `#8E8E93` |
| Accent (progress ring, seçili) | Warm amber/gold | `#F5A623` |
| Card border | Hafif gri | `rgba(0,0,0,0.06)` |
| Button background | Beyaz + shadow | `#FFFFFF` |
| Divider | Açık gri | `#E5E5EA` |
| Toggle seçili bg | Koyu (#1A1A1A) | `#1A1A1A` |
| Toggle seçili text | Beyaz | `#FFFFFF` |
| Toggle seçili değil text | Açık gri | `#8E8E93` |

### Dark Theme
| Rol | Renk | Kod |
|-----|------|-----|
| Background | Siyah | `#000000` |
| Surface | Koyu gri | `#1C1C1E` |
| Card overlay | Transparent -> siyah | `transparent -> rgba(0,0,0,0.55)` |
| Primary text | Beyaz | `#FFFFFF` |
| Secondary text | Orta gri | `#8E8E93` |

---

## Tipografi

| Kullanım | Font | Boyut | Ağırlık | Renk | Ekstra |
|----------|------|-------|---------|------|--------|
| Etkinlik adı (kart) | Poppins | 24px | Bold (w700) | Beyaz | text-shadow, center aligned |
| Geri sayım label (kart) | Poppins | 12px | Medium (w500) | Beyaz %80 | uppercase, letter-spacing: 2px, center |
| Header pill | Poppins | 15px | Bold (w700) | #1A1A1A | letter-spacing: -0.5 |
| Toggle label | Poppins | 15px | Bold (w700) | - | letter-spacing: -0.5 |
| Settings başlık | Poppins | 18px | Semibold (w600) | #1A1A1A | - |
| Settings item | Poppins | 16px | Medium (w500) | #1A1A1A | - |
| Countdown circle sayı | Poppins | 22px | Bold (w700) | Beyaz | - |
| Countdown circle label | Poppins | 9px | Medium (w500) | Beyaz %70 | - |

---

## Header Tasarımı

### Layout: `[≡]  [#ozelgunleriunutma]  [+]`

### Hamburger Butonu (Sol)
- Boyut: 44x44px, tam yuvarlak
- Background: beyaz, border: 1px rgba(0,0,0,0.06)
- Shadow: 0 2px 8px rgba(0,0,0,0.08)
- İkon: **3 yatay çizgi**, 18px genişlik, 1.5px kalınlık, #1A1A1A
- Tıklanınca: Tam sayfa Ayarlar ekranı (slide-in soldan)

### Merkez Pill
- "#ozelgunleriunutma" yazısı (kategori seçiliyse kategori adı)
- Background: beyaz, pill-shape (border-radius: 24px)
- Border: 1px rgba(0,0,0,0.06), shadow: 0 2px 8px rgba(0,0,0,0.08)
- Font: Poppins 15px, w700, letter-spacing: -0.5
- Tıklanınca: Kategori bottom sheet

### Plus Butonu (Sağ)
- Hamburger ile birebir aynı boyut/shadow/border
- İkon: Icons.add, 22px, ince

---

## Kart Tasarımı

### Boyutlar
- Yükseklik: 190px, tam genişlik (ekran - 32px)
- Border-radius: 20px
- Kartlar arası: 14px (7px + 7px padding)
- Shadow: 0 4px 16px rgba(0,0,0,0.08)
- Border: 1px rgba(0,0,0,0.06)

### Katmanlar
1. **Fotoğraf:** Kategori resmi, BoxFit.cover
2. **Gradient:** Alt %55, transparent -> rgba(0,0,0,0.55)
3. **Sağ üst:** Geri sayım dairesi (56x56)
4. **Alt orta:** Geri sayım text + etkinlik adı (center aligned)

### Sağ Üst — Geri Sayım Dairesi
- Dış boyut: 56x56px
- CircularProgressIndicator: 3px kalınlık, accent renk (#F5A623)
- Glow: BoxShadow accent %40 opacity, blur 8px
- İç daire: 46x46, backdrop blur, rgba(255,255,255,0.2)
- Border: 1px rgba(255,255,255,0.3)
- Sayı: Poppins 22px bold beyaz
- Label: Poppins 9px medium beyaz %70 ("GÜN", "SAAT", "ÖNCE", "BUGÜN")

### Alt Orta — Yazılar (CENTER ALIGNED)
- Geri sayım: "7 GÜN SONRA" — uppercase, 12px, letter-spacing 2, beyaz %80
- Etkinlik adı: 24px, bold, beyaz, text-shadow (0 2px 8px rgba(0,0,0,0.5))
- **Tarih YOK, kategori badge YOK**

### Tap Animasyonu
- Scale: 0.98, 100ms, easeOut
- Haptic: lightImpact (tap), mediumImpact (long-press)

---

## Alt Toggle (Floating Pill)

- Header pill ile AYNI tasarım dili
- Background: beyaz, border-radius: 24px
- Border: 1px rgba(0,0,0,0.06)
- Shadow: 0 2px 8px rgba(0,0,0,0.08)
- Padding: 4px

### Seçenekler: "Geçmiş" | "Yaklaşan"
- Seçili: koyu bg (#1A1A1A) + beyaz text
- Seçili değil: transparent bg + gri text (#8E8E93)
- Font: Poppins 15px, w700, letter-spacing: -0.5
- Geçiş: AnimatedContainer 200ms
- Haptic: selectionClick

---

## Ayarlar Sayfası (Tam Sayfa)

### Açılış
- Soldan sağa slide animation (350ms, easeOutCubic)
- Tam ekran sayfa (Navigator.push)

### Layout
- Background: #F5F5F0 (krem/bej)
- Header: Siyah yuvarlak X butonu (44x44) + "Ayarlar" başlık (ortada)
- Menü: Rounded beyaz kartlar, 8px boşluk

### Menü Öğeleri
| İkon | Label |
|------|-------|
| tune_rounded | Tercihler |
| dark_mode_outlined | Gece Modu |
| calendar_today_outlined | Takvim Bağla |
| help_outline_rounded | Destek |
| chat_bubble_outline_rounded | Öneriler |
| info_outline_rounded | Hakkında |

### Kart Stili
- Background: beyaz, border-radius: 16px
- Padding: 20px horizontal, 18px vertical
- Sol: ikon (22px, gri) + yazı (Poppins 16px, medium)
- Sağ: chevron_right (22px, gri)

---

## Animasyonlar

| Eleman | Animasyon | Detay |
|--------|-----------|-------|
| Kart tap | Scale down | 0.98, 100ms, easeOut |
| Kart tap | Haptic | lightImpact |
| Kart long-press | Haptic | mediumImpact |
| Tab değiştirme | Haptic | selectionClick |
| Buton tap | Haptic | lightImpact |
| Bottom sheet | Haptic | selectionClick |
| Kart listesi | Fade-in | Staggered, 60ms delay per item |
| Ayarlar sayfası | Slide-in | Soldan, 350ms, easeOutCubic |
| Toggle | Color transition | AnimatedContainer, 200ms |
| Konfeti | CustomPainter | D-Day, 60 parçacık, 4sn döngü |
