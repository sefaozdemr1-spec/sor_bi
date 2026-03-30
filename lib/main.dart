import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/ana_sayfa_root.dart';
import 'screens/giris_sayfasi.dart';

// 🛡️ SORBİ VİTRİN & TEMA MOTORU
const bool isVitrinModu = true; 
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark); // Varsayılan Mürdüm

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!isVitrinModu) {
    try { await Firebase.initializeApp(); } catch (e) { print(e); }
  }
  runApp(const SorBiApp());
}

class SorBiApp extends StatelessWidget {
  const SorBiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SorBi',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // 🌙/☀️ Canlı Değişim!

          // ☀️ GÜNDÜZ MODU (Ferah & İnci Beyazı)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            colorSchemeSeed: Colors.deepPurpleAccent,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
            cardTheme: CardThemeData(color: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: Colors.deepPurpleAccent),
          ),

          // 🌙 GECE MODU (Sizin Sevdiğiniz Lüks Mürdüm)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F0F12),
            colorSchemeSeed: Colors.deepPurpleAccent,
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF16161D), foregroundColor: Colors.white, elevation: 0),
            cardTheme: CardThemeData(color: const Color(0xFF1C1C24), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF16161D), selectedItemColor: Colors.pinkAccent),
          ),

          home: isVitrinModu ? const AnaSayfaRoot() : _AuthSwitch(),
        );
      }
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return snapshot.hasData ? const AnaSayfaRoot() : const GirisSayfasi();
      },
    );
  }
}
