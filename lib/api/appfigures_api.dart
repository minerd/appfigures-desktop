import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

/// API'den dönen hata; UI'da kullanıcıya gösterilebilir.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'API $statusCode: $message';
}

/// Hesap kimliği (kök endpoint /v2/ cevabı).
class Account {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String planName;
  final int dailyUsed;
  final int dailyLimit;
  final List<String> features;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.planName,
    required this.dailyUsed,
    required this.dailyLimit,
    required this.features,
  });

  factory Account.fromJson(Map<String, dynamic> j) {
    final user = (j['user'] ?? {}) as Map<String, dynamic>;
    final usage = (j['usage'] ?? {}) as Map<String, dynamic>;
    final sub = (j['current_subscription'] ?? {}) as Map<String, dynamic>;
    return Account(
      id: (user['id'] ?? 0) as int,
      name: (user['name'] ?? '') as String,
      email: (user['email'] ?? '') as String,
      avatarUrl: user['avatar_url'] as String?,
      planName: (sub['plan_name'] ?? 'Bilinmiyor') as String,
      dailyUsed: (usage['daily_used'] ?? 0) as int,
      dailyLimit: (usage['daily_limit'] ?? 0) as int,
      features: ((j['accessible_features'] ?? []) as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Appfigures REST API v2 istemcisi.
///
/// Kimlik doğrulama: HTTP Basic (email:şifre) + `X-Client-Key` header.
/// (Resmi olarak deprecated ama hâlâ çalışıyor; PAT/OAuth'a geçiş kolay.)
class AppfiguresApi {
  String email;
  String password;
  String clientKey;

  AppfiguresApi({
    String? email,
    String? password,
    String? clientKey,
  })  : email = email ?? AppConfig.defaultEmail,
        password = password ?? AppConfig.defaultPassword,
        clientKey = clientKey ?? AppConfig.defaultClientKey;

  Map<String, String> get _headers {
    final basic = base64Encode(utf8.encode('$email:$password'));
    return {
      'Authorization': 'Basic $basic',
      'X-Client-Key': clientKey,
      'Accept': 'application/json',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(AppConfig.baseUrl);
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return base.replace(
      path: '${base.path}$cleaned',
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    final res = await http.get(_uri(path, query), headers: _headers);
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    String msg = 'İstek başarısız';
    if (body is Map && body['message'] != null) {
      msg = body['message'].toString();
    }
    throw ApiException(res.statusCode, msg);
  }

  /// Kök endpoint — kimlik doğrulamayı test eder, hesap bilgisini döndürür.
  Future<Account> login() async {
    final data = await _get('');
    return Account.fromJson(data as Map<String, dynamic>);
  }

  /// Hesaba bağlı (takip edilen) ürünler.
  Future<List<dynamic>> myProducts({int count = 50}) async {
    final data = await _get('products/mine', {'count': count});
    if (data is Map && data['results'] is List) return data['results'] as List;
    return const [];
  }

  /// Keyword arama. Free planda boş [] döner; ASO planında dolu gelir.
  /// [type] = 'competitor' verilirse rakip keyword raporu denenir.
  Future<List<dynamic>> keywords({
    required String term,
    String country = 'US',
    String? type,
  }) async {
    final q = <String, dynamic>{'term': term, 'country': country};
    if (type != null) q['type'] = type;
    final data = await _get('keywords', q);
    if (data is List) return data;
    return const [];
  }

  /// ASO keyword rank trendleri (takip edilen ürünler için).
  Future<dynamic> asoRanks({
    required String products,
    String countries = 'US',
  }) {
    return _get('aso', {
      'group_by': 'keyword',
      'products': products,
      'countries': countries,
    });
  }

  /// Bir uygulamanın yorumları (sahip olunan ürünler için).
  Future<List<dynamic>> reviews({
    String? products,
    int count = 25,
    String? lang,
  }) async {
    final q = <String, dynamic>{'count': count};
    if (products != null) q['products'] = products;
    if (lang != null) q['lang'] = lang;
    final data = await _get('reviews', q);
    if (data is Map && data['reviews'] is List) return data['reviews'] as List;
    if (data is List) return data;
    return const [];
  }
}
