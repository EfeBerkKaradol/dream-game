# itch.io web sürümü

Oyun tarayıcıda oynanır; telefonda da tablette de dokunmatikle çalışır. Ücretsiz, reklamsız.

## Web sürümünü derlemek

Proje içinde hazır bir **Web** dışa aktarma ayarı var (`export_presets.cfg`).

1. Godot'ta **Editor > Manage Export Templates > Download and Install** (bir kez yapılır).
2. **Project > Export**, soldan **Web**'i seç, **Export Project**. Dosyalar `export/web/` klasörüne çıkar (git'e girmez).
3. `export/web` içindeki **tüm dosyaları** tek bir zip yap (klasörü değil, içindekileri). `index.html` zip'in en üstünde olmalı.

Ayarların kısa açıklaması:

- **Thread desteği kapalı.** Böylece itch.io'da ek bir ayar (SharedArrayBuffer) gerekmez, iPhone Safari'de de açılır.
- **Telefon dik tutulursa** oyun yerine "Telefonu yan çevir" ekranı çıkar.
- Uzun basınca çıkan menü, metin seçme ve iki parmakla yakınlaştırma kapalı; çocuk yanlışlıkla oyundan çıkmaz.
- Açılışta Godot logosu yerine oyunun gece mavisi görünür.

## itch.io'ya yükleme

1. [itch.io](https://itch.io/register) hesabı aç (ücretsiz). Sonra **Dashboard > Create new project**.
2. Aşağıdaki ayarları doldur, zip'i yükle.
3. **Visibility: Draft** ile kaydet, **View page** ile kendi telefonunda dene.
4. Her şey yolundaysa **Public** yap. Önce sadece tanıdık ailelere göstermek istersen **Restricted** seçip şifre koyabilirsin.

### Proje ayarları

| Alan | Değer |
| --- | --- |
| Title | Rüya Postası |
| Project URL | `ruya-postasi` |
| Short description | Gece postacısı Nil'le karışan rüyaları sahiplerine ulaştır. 6–8 yaş için sakin bir macera. |
| Classification | Games |
| Kind of project | **HTML** |
| Release status | Prototype |
| Pricing | No payments |
| Uploads | `ruya-postasi-web.zip`, **This file will be played in the browser** işaretli |
| Embed options > Viewport dimensions | 960 × 540 |
| Embed options > Mobile friendly | işaretli, Orientation: **Landscape** |
| Embed options > Fullscreen button | işaretli |
| Embed options > Automatically start on page load | işaretsiz (çocuk "Run game"e kendisi dokunsun, ses de böylece sorunsuz açılır) |
| Embed options > SharedArrayBuffer support | işaretsiz |
| Genre | Adventure |
| Tags | `kids`, `family-friendly`, `cozy`, `relaxing`, `cute`, `short`, `point-and-click`, `turkish` |
| AI generation disclosure | Yes (kod ve kodla çizilen görseller yapay zekâ yardımıyla yapıldı) |
| Inputs | Mouse, Touchscreen |
| Languages | Turkish |
| Accessibility | Okuma gerektirmeyen bulmacalar; zaman sınırı yok |
| Cover image | 630 × 500 kapak görseli |
| Screenshots | `docs/ekran` içindeki görüntüler |
| Visibility | Önce Draft, sonra Public |

### Sayfa metni (Description)

> **Rüya Postası** 🌙✉️
>
> Kasabada herkes uyurken genç postacı Nil işe başlar: rüyaları sahiplerine ulaştırmak! Ama bu gece rüyalar karışmış ve sokağa saçılmış. Ateşböceği Pırıl'la birlikte rüyaları topla, doğru zarfa koy ve her rüyanın içine girip küçük bir sorunu çöz.
>
> - Huysuz bulutu gıdıkla, fırıncı Halim dev simidine ulaşsın.
> - Balinanın şarkısını dinle ve aynısını çal.
> - Aynaları çevir, fenerin ışığı kayıp kâğıt gemiyi bulsun.
>
> Sabah olunca kasabalılar sana teşekkür eder. Kaybetmek yok, acele yok, reklam yok.
>
> **Kimler için:** 6–8 yaş, ailece birlikte de oynanabilir. Okuma bilmeyen çocuklar Pırıl'ın konuşmalarını bir büyükten dinleyebilir.
> **Süre:** Yaklaşık 10 dakika.
> **Nasıl oynanır:** Ekrana dokun ya da tıkla. Telefonda yan çevirip tam ekran oyna.
>
> Bu bir **ilk deneme sürümü** (Bölüm 1: Fırın Sokağı). Çocuğunuz nerede takıldı, neyi sevdi? Yorumlara yazarsanız çok sevinirim. 💛
