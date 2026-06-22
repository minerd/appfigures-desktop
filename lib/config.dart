/// Appfigures API yapılandırması.
///
/// GÜVENLİK: Bu dosyada ASLA gerçek şifre/anahtar tutma — repo public.
/// Kimlik bilgileri uygulama içindeki "Ayarlar" ekranından girilir ve
/// cihazda lokal olarak (shared_preferences) saklanır.
///
/// İstersen derleme sırasında --dart-define ile de verebilirsin:
///   flutter run --dart-define=AF_EMAIL=... \
///               --dart-define=AF_PASSWORD=... \
///               --dart-define=AF_CLIENT_KEY=...
class AppConfig {
  /// Appfigures API kök adresi (sonunda / olmalı).
  static const String baseUrl = 'https://api.appfigures.com/v2/';

  /// Varsayılan e-posta (HTTP Basic kullanıcı adı). Boş = Ayarlar'dan gir.
  static const String defaultEmail =
      String.fromEnvironment('AF_EMAIL', defaultValue: '');

  /// Varsayılan şifre (HTTP Basic parola). Boş = Ayarlar'dan gir.
  static const String defaultPassword =
      String.fromEnvironment('AF_PASSWORD', defaultValue: '');

  /// API Client anahtarı — X-Client-Key header'ında gönderilir.
  static const String defaultClientKey =
      String.fromEnvironment('AF_CLIENT_KEY', defaultValue: '');
}
