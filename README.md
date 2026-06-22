# Appfigures Desktop (Flutter)

Appfigures API v2'ye bağlanan, **Windows** için Flutter masaüstü uygulaması.
Açılışta arka planda giriş yapar; hesap durumu, keyword arama, rakip keyword
ve yorumlar ekranlarını sunar.

## Özellikler

- **Hesap** — Arka planda API girişi, kullanıcı/plan/günlük kullanım ve
  erişilebilir özelliklerin listesi (canlı bağlantı rozeti).
- **Keyword** — `GET /v2/keywords?term=&country=` ile keyword arama.
- **Rakip Keyword** — `reports/competitor-keywords` karşılığı (ASO).
- **Yorumlar** — `GET /v2/reviews` ile son yorumlar.
- **Ayarlar** — Kimlik bilgilerini gir, cihazda lokal sakla (`shared_preferences`).

> **Not:** Keyword / Rakip Keyword verisi Appfigures'ın **ASO** (ücretli)
> özelliğine bağlıdır. Hesabın `accessible_features` listesinde `aso` yoksa
> bu uçlar `200` döner ama boş gelir.

## Kimlik Doğrulama

HTTP Basic (`email:şifre`) + `X-Client-Key` header. Client Key'i
[appfigures.com/developers/keys](https://appfigures.com/developers/keys)
adresinden bir **API Client** oluşturarak alırsın.

> Güvenlik: Kaynak koda kimlik bilgisi gömme. Uygulama içindeki **Ayarlar**
> ekranından gir; istersen derlemede `--dart-define` ile de verebilirsin:
>
> ```bash
> flutter run -d windows \
>   --dart-define=AF_EMAIL=you@example.com \
>   --dart-define=AF_PASSWORD=*** \
>   --dart-define=AF_CLIENT_KEY=***
> ```

## Çalıştırma

```bash
flutter pub get
flutter run -d windows      # veya: flutter build windows
```

## Lisans

MIT
