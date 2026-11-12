import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final container = InjectionContainer(prefs: prefs);
  runApp(MultiProvider(providers: container.providers(), child: const MorseApp()));
  // Consent form (EEA/UK/CH only), then the ads SDK and a preloaded rewarded ad.
  container.adService.initialize();
}
