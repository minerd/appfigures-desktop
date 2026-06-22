import 'package:flutter/material.dart';

/// Her ekranın üstündeki başlık + açıklama.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 30, color: t.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: t.textTheme.bodySmall
                ?.copyWith(color: t.colorScheme.outline)),
          ],
        ),
      ],
    );
  }
}

/// Bilgi/uyarı kutusu (örn. plan kısıtı mesajı).
class InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.tertiary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
