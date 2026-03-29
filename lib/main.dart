import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/ana_sayfa_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCK-JmispGc-anYzyMM1GaRjYjXBghIhyo",
      authDomain: "sorbi-fc28c.firebaseapp.com",
      projectId: "sorbi-fc28c",
      storageBucket: "sorbi-fc28c.firebasestorage.app",
      messagingSenderId: "915033157628",
      appId: "1:915033157628:web:b99c694f8c835e75dd0c79",
      measurementId: "G-3MDQ3E4J9T",
    ),
  );
  runApp(const SorBiApp());
}

class SorBiApp extends StatelessWidget {
  const SorBiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SorBi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA), // Pırıl pırıl temiz Gündüz beyazı/grisi
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.deepPurpleAccent.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AnaSayfaRoot(),
    );
  }
}
