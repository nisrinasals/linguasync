import 'package:flutter_test/flutter_test.dart';
import 'package:linguasync/data/provider/storage_provider.dart';
import 'package:linguasync/main.dart';

void main() {
  testWidgets('App starts test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(LinguaSyncApp(storageProvider: StorageProvider()));
  });
}
