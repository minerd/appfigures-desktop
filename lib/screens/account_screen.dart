import 'package:flutter/material.dart';

import '../main.dart' show appState;
import '../widgets/common.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'Hesap',
                subtitle: 'Appfigures API ile arka planda giriş durumu',
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 20),
              if (appState.loggingIn)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (appState.loginError != null)
                InfoBanner(
                  message: 'Giriş başarısız: ${appState.loginError}',
                  icon: Icons.error_outline,
                  color: t.colorScheme.error,
                )
              else if (appState.account != null) ...[
                _accountCard(context),
                const SizedBox(height: 16),
                _usageCard(context),
                const SizedBox(height: 16),
                _featuresCard(context),
              ],
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: appState.loggingIn ? null : () => appState.login(),
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden Bağlan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _accountCard(BuildContext context) {
    final a = appState.account!;
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: t.colorScheme.primaryContainer,
              backgroundImage:
                  a.avatarUrl != null ? NetworkImage(a.avatarUrl!) : null,
              child: a.avatarUrl == null
                  ? Text(a.name.isNotEmpty ? a.name[0] : '?')
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.name,
                        style: t.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                  ],
                ),
                Text(a.email,
                    style: t.textTheme.bodyMedium
                        ?.copyWith(color: t.colorScheme.outline)),
                const SizedBox(height: 6),
                Chip(
                  label: Text(a.planName),
                  avatar: const Icon(Icons.workspace_premium, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Spacer(),
            Text('ID: ${a.id}',
                style: t.textTheme.bodySmall
                    ?.copyWith(color: t.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _usageCard(BuildContext context) {
    final a = appState.account!;
    final t = Theme.of(context);
    final ratio = a.dailyLimit == 0 ? 0.0 : a.dailyUsed / a.dailyLimit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Günlük API Kullanımı',
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text('${a.dailyUsed} / ${a.dailyLimit} istek',
                style: t.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _featuresCard(BuildContext context) {
    final a = appState.account!;
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Erişilebilir Özellikler',
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              a.features.contains('aso')
                  ? 'ASO/keyword erişimin açık.'
                  : 'Not: "aso" listede yok → keyword/rakip keyword datası boş gelir (ASO planı gerekir).',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in a.features)
                  Chip(
                    label: Text(f),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        t.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
