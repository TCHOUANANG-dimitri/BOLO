import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation Firebase
  // Si Firebase n'est pas configuré (google-services.json manquant),
  // l'app fonctionne en mode démo avec les données mock.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Mode démo : Firebase non configuré, données mock utilisées
  }

  runApp(const BoloApp());
}
