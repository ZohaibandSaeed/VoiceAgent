import 'package:flutter_test/flutter_test.dart';
import 'package:voice_agent_app/main.dart';

void main() {
  testWidgets('App renders VoiceAgentApp successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const VoiceAgentApp());
    expect(find.byType(VoiceAgentApp), findsOneWidget);
  });
}
