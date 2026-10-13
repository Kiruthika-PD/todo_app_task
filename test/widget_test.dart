import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/main.dart';

void main() {
  testWidgets('Task Space app displays its title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskSpaceApp());

    expect(find.text('Task Space'), findsOneWidget);
    expect(
      find.text('Your progress'),
      findsOneWidget,
    );
  });
}