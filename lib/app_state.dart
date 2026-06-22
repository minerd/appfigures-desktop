import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/appfigures_api.dart';
import 'config.dart';

/// Uygulama genelinde kimlik bilgilerini ve API istemcisini tutar.
/// Kimlik bilgileri cihazda (shared_preferences) saklanır; yoksa
/// config.dart'taki varsayılanlar kullanılır.
class AppState extends ChangeNotifier {
  static const _kEmail = 'af_email';
  static const _kPassword = 'af_password';
  static const _kClientKey = 'af_client_key';

  late AppfiguresApi api;
  Account? account;
  String? loginError;
  bool loggingIn = false;

  AppState() {
    api = AppfiguresApi();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    api = AppfiguresApi(
      email: prefs.getString(_kEmail) ?? AppConfig.defaultEmail,
      password: prefs.getString(_kPassword) ?? AppConfig.defaultPassword,
      clientKey: prefs.getString(_kClientKey) ?? AppConfig.defaultClientKey,
    );
    await login();
  }

  /// Arka planda giriş yapar (kök endpoint'i çağırır).
  Future<void> login() async {
    loggingIn = true;
    loginError = null;
    notifyListeners();
    if (api.email.isEmpty || api.clientKey.isEmpty) {
      account = null;
      loginError =
          'Kimlik bilgisi girilmemiş. Ayarlar ekranından e-posta, şifre ve '
          'Client Key gir (appfigures.com/developers/keys).';
      loggingIn = false;
      notifyListeners();
      return;
    }
    try {
      account = await api.login();
    } on ApiException catch (e) {
      loginError = '${e.statusCode} • ${e.message}';
    } catch (e) {
      loginError = e.toString();
    } finally {
      loggingIn = false;
      notifyListeners();
    }
  }

  Future<void> updateCredentials({
    required String email,
    required String password,
    required String clientKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPassword, password);
    await prefs.setString(_kClientKey, clientKey);
    api = AppfiguresApi(
      email: email,
      password: password,
      clientKey: clientKey,
    );
    await login();
  }

  bool hasFeature(String f) => account?.features.contains(f) ?? false;
}
