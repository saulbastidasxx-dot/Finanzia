import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzia/services/preferences_service.dart';

void main() {
  test('privacy mode persists', () async {
    SharedPreferences.setMockInitialValues({});
    final p = PreferencesService();
    expect(await p.loadPrivacyMode(), false);
    await p.savePrivacyMode(true);
    expect(await p.loadPrivacyMode(), true);
  });
}
