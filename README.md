# Rüya Postası: Bölüm 1 prototipi

6–8 yaş için, ailece oynanabilen rahat bir macera oyununun ilk oynanabilir prototipi.
Godot 4.5 ile yapıldı. Tüm görseller şimdilik kodla çizilen geçici şekiller, sesler de kodla üretilen bip sesleri.

## Nasıl açılır

1. [godotengine.org](https://godotengine.org/download) adresinden **Godot 4.5**'i indir (ücretsiz, kurulum gerektirmez).
2. Godot'u aç, **Import** de ve bu klasördeki `project.godot` dosyasını seç.
3. Sağ üstteki ▶ (F5) ile oyunu başlat. Fare tıklaması dokunma gibi çalışır.

## Akış (yaklaşık 4–5 dakika)

| Sahne | Dosya | Ne olur |
| --- | --- | --- |
| Açılış | `scenes/title.tscn` | "Oyna" butonu |
| Gece turu | `scenes/night_town.tscn` | Ekrana dokun, Nil yürür; 3 rüya parçasını topla. Uzun süre durursan Pırıl en yakın parçanın üstüne uçar (ipucu). |
| Zarf masası | `scenes/envelope_table.tscn` | Parçaları, pulundaki resim aynı olan zarfa sürükle. Okuma gerekmez. |
| Halim'in rüyası | `scenes/dream_clouds.tscn` | Parlayan buluta dokun, Nil zıplar. Huysuz bulutu 3 kez gıdıkla, güler ve yol açılır. Dev simite ulaş. |
| Sabah | `scenes/morning.tscn` | Dokundukça konuşma ilerler; rüya kartı, değirmen 1/5, Dede Yusuf'un anısı, "İyi geceler". |

## Kod yapısı

- `scripts/game_state.gd`: oyun durumu (toplananlar, teslimler, değirmen ilerlemesi). Otomatik yüklenir.
- `scripts/sfx.gd`: kodla üretilen ses efektleri. Gerçek sesler gelince burası değişecek.
- `scripts/art.gd`: tüm geçici çizimler (Nil, Pırıl, evler, bulutlar, simgeler). Gerçek çizimler hazır olunca bu fonksiyonların yerine Sprite2D gelecek; oyun mantığı aynı kalır.
- `scripts/ui.gd`: konuşma balonu ve büyük butonlar.
- `tests/playtest.tscn`: tüm bölümü kendi kendine oynayan ve ekran görüntüsü alan otomatik test. Godot'da bu sahneyi açıp F6 ile çalıştırabilirsin.

## Sıradaki işler

- [ ] 3–5 çocuğa oynat; nerede takıldıklarını not et.
- [ ] Nil, Pırıl ve Fırın Sokağı için görsel stil (Krita ya da Inkscape).
- [ ] Pırıl ve Halim için kendi sesinle seslendirme (Audacity).
- [ ] Web'e dışa aktarıp itch.io'da ücretsiz test sürümü yayınlamak (Godot: Editor > Manage Export Templates, sonra Project > Export > Web).
