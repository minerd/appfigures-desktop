import 'package:flutter/material.dart';

import '../api/appfigures_api.dart';
import '../main.dart' show appState;
import '../widgets/common.dart';

class KeywordScreen extends StatefulWidget {
  const KeywordScreen({super.key});

  @override
  State<KeywordScreen> createState() => _KeywordScreenState();
}

class _KeywordScreenState extends State<KeywordScreen> {
  final _termCtrl = TextEditingController(text: 'fitness');
  String _country = 'US';
  bool _loading = false;
  String? _error;
  List<dynamic>? _results;

  static const _countries = ['US', 'GB', 'DE', 'TR', 'JP', 'FR', 'CA', 'AU'];

  Future<void> _search() async {
    final term = _termCtrl.text.trim();
    if (term.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = null;
    });
    try {
      final r = await appState.api.keywords(term: term, country: _country);
      setState(() => _results = r);
    } on ApiException catch (e) {
      setState(() => _error = '${e.statusCode} • ${e.message}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _termCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Keyword Arama',
            subtitle: 'App Store / Google Play keyword verisi (/v2/keywords)',
            icon: Icons.search,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _termCtrl,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Keyword',
                    hintText: 'örn. fitness, photo editor',
                    prefixIcon: Icon(Icons.tag),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: _country,
                  decoration: const InputDecoration(
                    labelText: 'Ülke',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in _countries)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _country = v ?? 'US'),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Ara'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return InfoBanner(
        message: 'Hata: $_error',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
    if (_results == null) {
      return const InfoBanner(
        message: 'Bir keyword yazıp Ara’ya bas.',
        icon: Icons.lightbulb_outline,
      );
    }
    if (_results!.isEmpty) {
      return const InfoBanner(
        message:
            'Sonuç boş döndü. Bu büyük ihtimalle plan kısıtı: hesabın ASO '
            '(keyword) özelliğine sahip değil. Plan yükseltilince aynı arama '
            'dolu sonuç döndürür.',
        icon: Icons.lock_outline,
        color: Colors.orange,
      );
    }
    return ListView.separated(
      itemCount: _results!.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final k = _results![i];
        final m = k is Map ? k : <String, dynamic>{};
        return ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text(m['keyword']?.toString() ?? m['term']?.toString() ?? '$k'),
          subtitle: Text(m.entries
              .where((e) => e.key != 'keyword' && e.key != 'term')
              .map((e) => '${e.key}: ${e.value}')
              .join('  •  ')),
        );
      },
    );
  }
}
