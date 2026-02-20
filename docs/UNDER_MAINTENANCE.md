# Bakımda / Geliştirme Aşamasındaki Sayfalar

Bu doküman, uygulama içinde şu an **geliştirme aşamasında** olan sayfa ve bölümleri listeler. Bu alanlar `assets/lottie/Under Maintenance.json` Lottie animasyonu ile "Geliştirme aşamasında" mesajı gösterir.

**Amaç:** Bu sayfalar henüz tamamlanmadığı için devlog veya demo amaçlı kullanıcıya bilgilendirici bir görünüm sunmak. Geliştirme olmadığı izlenimi vermemek, aksine "yakında gelecek" hissi yaratmak için bu banner kullanılır.

---

## Tam Sayfa (Full Page)

| Sayfa | Route | Açıklama |
|-------|-------|----------|
| **Mağaza** | `/shop` | Mağaza ekranı — power-up, kozmetik, unlock ürünleri |
| **Sıralama** | `/leaderboard` | Haftalık ve tüm zamanlar sıralaması |

---

## Bölüm (Inline Section)

| Bölüm | Konum | Açıklama |
|-------|-------|----------|
| **Kupa Sergisi** | Profil → Kupa Sergim | Haftalık sıralama kupaları vitrini |
| **Satın Alma** | Profil → Ayarlar → Satın Alma | Reklam kaldır, coin satın al, geri yükle |

---

## Teknik Notlar

- **Widget:** `lib/presentation/widgets/under_maintenance_widget.dart`
- **Lottie:** `assets/lottie/Under Maintenance.json`
- `fullPage: true` — orta ekranda büyük animasyon
- `fullPage: false` — kompakt inline banner
