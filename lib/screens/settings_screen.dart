import 'package:flutter/material.dart';

import '../main.dart' show appState;
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _emailCtrl = TextEditingController(text: appState.api.email);
  late final _passCtrl = TextEditingController(text: appState.api.password);
  late final _keyCtrl = TextEditingController(text: appState.api.clientKey);
  bool _obscure = true;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await appState.updateCredentials(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      clientKey: _keyCtrl.text.trim(),
    );
    setState(() => _saving = false);
    if (!mounted) return;
    final ok = appState.account != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Kaydedildi ve giriş başarılı ✓'
            : 'Kaydedildi ama giriş başarısız: ${appState.loginError}'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Ayarlar',
            subtitle: 'Appfigures API kimlik bilgileri',
            icon: Icons.settings,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _keyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Client Key (X-Client-Key)',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Kaydet ve Bağlan'),
                ),
                const SizedBox(height: 20),
                const InfoBanner(
                  message:
                      'Daha güvenli yöntem: appfigures.com/developers/keys '
                      'üzerinden Personal Access Token (PAT) oluşturup şifre '
                      'yerine onu kullanmak. Mevcut giriş HTTP Basic + Client '
                      'Key ile çalışıyor (deprecated ama aktif).',
                  icon: Icons.shield_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
