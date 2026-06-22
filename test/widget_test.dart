import 'package:flutter_test/flutter_test.dart';

import 'package:appfigures/main.dart';

void main() {
  testWidgets('Uygulama açılır ve navigasyon görünür', (tester) async {
    await tester.pumpWidget(const AppfiguresApp());
    // Navigasyon etiketleri görünmeli.
    expect(find.text('Hesap'), findsWidgets);
    expect(find.text('Keyword'), findsWidgets);
    expect(find.text('Rakip Keyword'), findsWidgets);
  });
}
