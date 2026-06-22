import 'package:flutter/material.dart';

import '../api/appfigures_api.dart';
import '../main.dart' show appState;
import '../widgets/common.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = false;
  String? _error;
  List<dynamic>? _reviews;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _reviews = null;
    });
    try {
      final r = await appState.api.reviews(count: 25);
      setState(() => _reviews = r);
    } on ApiException catch (e) {
      setState(() => _error = '${e.statusCode} • ${e.message}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Yorumlar',
            subtitle: 'Takip ettiğin uygulamaların son yorumları (/v2/reviews)',
            icon: Icons.reviews,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.download),
            label: const Text('Yorumları Getir'),
          ),
          const SizedBox(height: 16),
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
        message:
            'Hata: $_error\n\nNot: Yorumlar yalnızca hesabına bağlı (sahip '
            'olduğun) uygulamalar için gelir. Bu hesapta takip edilen ürün yok.',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
    if (_reviews == null) {
      return const InfoBanner(
        message: 'Yorumları getirmek için butona bas.',
        icon: Icons.lightbulb_outline,
      );
    }
    if (_reviews!.isEmpty) {
      return const InfoBanner(
        message:
            'Yorum bulunamadı. Bu hesapta takip edilen ürün yok; uygulama '
            'bağlandığında yorumlar burada listelenir.',
        icon: Icons.inbox_outlined,
        color: Colors.orange,
      );
    }
    return ListView.separated(
      itemCount: _reviews!.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = _reviews![i] as Map<String, dynamic>;
        final stars = (m['stars'] ?? m['rating'] ?? 0);
        final starInt = stars is num ? stars.round() : 0;
        return Card(
          child: ListTile(
            title: Text(m['title']?.toString() ?? '(başlıksız)',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(m['review']?.toString() ?? m['body']?.toString() ?? ''),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var s = 0; s < 5; s++)
                      Icon(
                        s < starInt ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    const SizedBox(width: 8),
                    Text(m['author']?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
