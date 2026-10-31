# Görsel dil: göz yormayan tasarım

Rüya Postası 6–8 yaş için yapılıyor ve çoğunlukla yatmadan önce oynanacak. Bu yüzden grafikler sıcak ve sevimli olmalı ama gözü yormamalı. Kodla çizilen bütün görseller (`scripts/art.gd`) ve ileride gelecek gerçek çizimler bu kurallara uyar.

## Renk

| Rol | Renk | Kod |
| --- | --- | --- |
| Kontur ve yazı | Mürekkep moru | `#3d3550` |
| Açık zemin, balon | Krem | `#fff6e6` |
| Gece göğü | Mürekkep mavisi → yumuşak çivit | `#1f2547` → `#3b4277` |
| Gündüz göğü | Açık mavi → kırık beyaz | `#a8d3e6` → `#eef3e8` |
| Rüya göğü | Lavanta → şeftali | `#e9dcf0` → `#f8e3d6` |
| Vurgu renkleri | Kayısı, gül, adaçayı, toz mavi, tereyağı, lavanta | `#f0b27a` `#e3a4a4` `#9cc5a1` `#7fa7c9` `#f5d98b` `#b9a7d6` |

- Saf siyah (`#000`) ve saf beyaz (`#fff`) kullanılmaz.
- Kontur, dolgu renginin yaklaşık %30 koyusudur; siyah çizgi yok.
- Gece sahneleri koyu değil, yumuşak mürekkep mavisi; ışık kaynakları (pencere, fener, Pırıl) sıcak ve hafif.
- Kasabalıların renkleri sabittir: Halim kayısı, Ruhi toz mavi, Leyla gül. Çocuk, rengi kişiyle eşleştirmeyi öğrenir.

## Şekil

- Bütün köşeler yuvarlak, bütün kenarlar yumuşak (antialias).
- Işıklar keskin daire değil, çok katmanlı saydam hale olarak çizilir.
- Gölgeler yumuşak, %15–20 saydam mürekkep rengi.
- Arka planda 2–3 katmanlı tepeler; uzak katman daha yavaş kayar (derinlik hissi).

## Hareket

- Bütün hareketler yavaş ve küçük: süzülme 1–2 saniyelik döngüde, birkaç piksel.
- Hızlı yanıp sönme, titreşen ışık ve ani parlama yok.
- Butonlar çok hafif "nefes alır" (%3 büyüme, 2,4 saniyelik döngü).
- Doğru hamlede küçük yıldız saçılır; yanlış hamlede kırmızı ya da sarsıntı yok, sadece nazik bir cümle.

## Yazı ve ses

- Yazı tipi: Nunito (yuvarlak hatlı, Türkçe karakterli, OFL lisanslı), kalın ağırlık.
- Balon yazısı en az 30 px; isimler 22 px.
- Sesler yumuşak sinüs tonları, düşük ses seviyesi, keskin başlangıç yok.
