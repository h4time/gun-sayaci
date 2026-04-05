import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gun_sayaci/widgets/countdown_card.dart';
import 'package:gun_sayaci/models/event_model.dart';

void main() {
  final event = EventModel(
    id: 'test-1',
    title: 'Çok Uzun Bir Etkinlik Adı Test Deneme Uzun',
    targetDate: DateTime.now().add(const Duration(days: 33)),
    category: 'Düğün/Yıldönümü',
  );

  // Test multiple screen widths × all card sizes
  final widths = [320.0, 375.0, 414.0, 428.0];
  final sizes = ['large', 'medium', 'small'];

  for (final w in widths) {
    for (final size in sizes) {
      testWidgets('$size @ ${w.toInt()}w — no overflow', (tester) async {
        tester.view.physicalSize = Size(w * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        FlutterError? caughtError;
        final oldHandler = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.toString().contains('overflowed')) {
            caughtError = details.exception as FlutterError;
          }
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  CountdownCard(
                    event: event,
                    onTap: () {},
                    onDelete: () {},
                    cardSize: size,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = oldHandler;
        expect(caughtError, isNull,
            reason: 'Overflow in "$size" @ ${w}w: $caughtError');
      });
    }
  }
}
