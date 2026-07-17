import 'package:flutter/material.dart';
import 'package:flutter_arms/features/home/presentation/pages/home_tab_page.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp() {
  return const MaterialApp(home: HomeTabPage());
}

void main() {
  group('HomeTabPage template surface', () {
    testWidgets('renders the home-page placeholder', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
