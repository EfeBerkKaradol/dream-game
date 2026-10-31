# Rüya Postası: Bölüm 1 prototipi

6–8 yaş için, ailece oynanabilen rahat bir macera oyununun ilk oynanabilir prototipi.
Godot 4.5 ile yapıldı. Görseller kodla çiziliyor (yumuşak, pastel, göz yormayan bir stil); sesler de kodla üretilen yumuşak tonlar. Yazı tipi Nunito (OFL lisanslı, `assets/fonts`).

## Nasıl açılır

1. [godotengine.org](https://godotengine.org/download) adresinden **Godot 4.5**'i indir (ücretsiz, kurulum gerektirmez).
2. Godot'u aç, **Import** de ve bu klasördeki `project.godot` dosyasını seç.
3. Sağ üstteki ▶ (F5) ile oyunu başlat. Fare tıklaması dokunma gibi çalışır.

## Akış (yaklaşık 8–10 dakika)

| Sahne | Dosya | Ne olur |
| --- | --- | --- |
| Açılış | `scenes/title.tscn` | "Oyna" butonu |
| Gece turu | `scenes/night_town.tscn` | Ekrana dokun, Nil yürür; 3 rüya parçasını topla. Uzun süre durursan Pırıl en yakın parçanın üstüne uçar (ipucu). |
| Zarf masası | `scenes/envelope_table.tscn` | Parçaları, pulundaki resim aynı olan zarfa sürükle. Okuma gerekmez. |
| Halim'in rüyası | `scenes/dream_clouds.tscn` | Parlayan buluta dokun, Nil zıplar. Huysuz bulutu 3 kez gıdıkla, güler ve yol açılır. Dev simite ulaş. |
| Ruhi'nin rüyası | `scenes/dream_whale.tscn` | Balina kabukları sırayla parlatıp şarkı söyler; aynı sırayla dokun. 3 tur (2, 3, 3 nota). Yanlışta balina şarkıyı yavaşça tekrar söyler. |
| Leyla'nın rüyası | `scenes/dream_light.tscn` | Aynalara dokun, döndür; fenerin ışığını kayıp kâğıt gemiye ulaştır. Işığın yolu her an görünür. |
| Sabah | `scenes/morning.tscn` | Dokundukça konuşma ilerler; üç kasabalı teşekkür eder, rüya kartları, değirmen 1/5, Dede Yusuf'un anısı, "İyi geceler". |

Görsel kurallar için: [docs/GORSEL_DIL.md](docs/GORSEL_DIL.md)

## Kod yapısı

- `scripts/game_state.gd`: oyun durumu (toplananlar, teslimler, değirmen ilerlemesi). Otomatik yüklenir.
- `scripts/sfx.gd`: kodla üretilen ses efektleri. Gerçek sesler gelince burası değişecek.
- `scripts/art.gd`: tüm çizimler ve renk paleti (Nil, Pırıl, kasabalılar, evler, bulutlar, balina, fener). Gerçek çizimler hazır olunca bu fonksiyonların yerine Sprite2D gelecek; oyun mantığı aynı kalır.
- `scripts/ui.gd`: konuşma balonu ve büyük butonlar.
- `tests/playtest.tscn`: tüm bölümü kendi kendine oynayan ve ekran görüntüsü alan otomatik test. Godot'da bu sahneyi açıp F6 ile çalıştırabilirsin.

## Sıradaki işler

- [ ] 3–5 çocuğa oynat; nerede takıldıklarını not et.
- [ ] Nil, Pırıl ve Fırın Sokağı için görsel stil (Krita ya da Inkscape).
- [ ] Pırıl ve Halim için kendi sesinle seslendirme (Audacity).
- [ ] itch.io'da ücretsiz web sürümünü yayınlamak: derleme ve sayfa ayarları [docs/ITCH.md](docs/ITCH.md) içinde.
