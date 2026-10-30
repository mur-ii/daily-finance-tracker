import 'package:shared_preferences/shared_preferences.dart';

const String _hasSeenOnboardingKey = 'has_seen_onboarding';

/// `true` bila user sudah menyelesaikan onboarding (bukan pertama kali buka).
Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_hasSeenOnboardingKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hasSeenOnboardingKey, true);
}
