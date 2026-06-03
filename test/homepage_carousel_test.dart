import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/view/homepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomepageCarousel uses a static placeholder for empty data',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('zh'),
          Locale('en'),
        ],
        home: Scaffold(
          body: HomepageCarousel(carousels: []),
        ),
      ),
    );

    expect(find.byType(CarouselSlider), findsNothing);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
