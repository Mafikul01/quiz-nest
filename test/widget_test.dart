import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_nest/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuizNestApp());
  });
}
