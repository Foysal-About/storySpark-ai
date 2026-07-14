import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyspark_ai/app/app.dart';
import 'package:storyspark_ai/features/onboarding/presentation/providers/onboarding_providers.dart';

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'onboarding_completed': true});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home tab shows greeting, featured story and empty state',
      (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Hi, Storyteller'), findsOneWidget);
    expect(find.text('The Dragon Who Lost His\nRoar'), findsOneWidget);
    expect(find.text('No stories yet'), findsOneWidget);
  });

  testWidgets('bottom nav switches between tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Your library is empty'), findsOneWidget);

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Grown-ups & account'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Recent stories'), findsOneWidget);
  });

  testWidgets('featured card opens the story reader', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('The Dragon Who Lost His\nRoar'));
    await tester.pumpAndSettle();

    expect(find.text('Story Time'), findsOneWidget);
    expect(find.text('Read Aloud'), findsOneWidget);
    // Featured story isn't in the library yet, so the reader offers to save.
    expect(find.text('Save Story'), findsOneWidget);
  });

  testWidgets('create flows are reachable from home', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Create a new story'));
    await tester.pumpAndSettle();

    expect(find.text('Build your story'), findsOneWidget);
    expect(find.text('Start your adventure'), findsOneWidget);
  });
}
