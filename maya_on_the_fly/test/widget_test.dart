import 'package:flutter_test/flutter_test.dart';
import 'package:maya_on_the_fly/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MayaOnTheFlyApp());
    expect(find.text('Maya on the Fly'), findsOneWidget);
  });
}
