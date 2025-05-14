import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swifty_companion/src/shared/widgets/glass_container.dart';

void main() {
  testWidgets('GlassContainer renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            child: Text('Test Content'),
          ),
        ),
      ),
    );

    // Verify the glass container is rendered
    expect(find.byType(GlassContainer), findsOneWidget);

    // Verify the child content is displayed
    expect(find.text('Test Content'), findsOneWidget);

    // Verify the ClipRRect is present (for rounded corners)
    expect(find.byType(ClipRRect), findsWidgets);

    // Verify the BackdropFilter is present (for blur effect)
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('GlassContainer applies custom properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            borderRadius: 20,
            color: Colors.blue.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(20),
            blur: 15,
            child: const Text('Custom Glass'),
          ),
        ),
      ),
    );

    // Find the Container with decoration
    final containerFinder = find.descendant(
      of: find.byType(BackdropFilter),
      matching: find.byType(Container),
    );

    expect(containerFinder, findsOneWidget);

    // Verify the custom padding is applied
    final container = tester.widget<Container>(containerFinder);
    expect(container.padding, const EdgeInsets.all(20));
  });
}
