import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_capsule/widgets/mood_selector.dart';

void main() {
  testWidgets('MoodSelector renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodSelector(
            selectedMood: null,
            onMoodSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('อารมณ์ตอนนี้'), findsOneWidget);
  });
}


