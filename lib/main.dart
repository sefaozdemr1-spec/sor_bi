import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/ana_sayfa_root.dart';
import 'screens/giris_sayfasi.dart';
import 'firebase_options.dart'; // 🚀 Manüel oluşturduğumuz options dosyası!

// ─────────────────────────────────────────────────────────
// 🛡️ SORBİ VİTRİN MODU
// → true:  Fake data ile çalışır (demo/investor gösterimi)
// → false: Gerçek Firebase backend'e bağlanır
// ─────────────────────────────────────────────────────────
const bool isVitrinModu = false; 

// 🎨 Canlı Tema Değiştirici (Mürdüm Gece / İnci Gündüz)
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase bağlantısı — sadece canlı modda
  if (!isVitrinModu) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('🔴 Firebase init hatası: $e');
    }
  }

  runApp(
    // 🧠 Riverpod: Tüm app'i ProviderScope ile sarıyoruz
    const ProviderScope(
      child: SorBiApp(),
    ),
  );
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
          themeMode: currentMode,

          // ☀️ GÜNDÜZ — İnci Beyazı
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            colorSchemeSeed: Colors.deepPurpleAccent,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.deepPurpleAccent,
            ),
          ),

          // 🌙 GECE — Lüks Mürdüm
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F0F12),
            colorSchemeSeed: Colors.deepPurpleAccent,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF16161D),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1C1C24),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF16161D),
              selectedItemColor: Colors.pinkAccent,
            ),
          ),

          home: isVitrinModu ? const AnaSayfaRoot() : const _AuthSwitch(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// 🔐 AUTH SWITCH — Giriş yapıldı mı kontrol et
// ─────────────────────────────────────────────────────────
class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Bağlantı kurulurken yükleniyor ekranı
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            ),
          );
        }
        // Kullanıcı varsa ana sayfa, yoksa giriş sayfası
        return snapshot.hasData ? const AnaSayfaRoot() : const GirisSayfasi();
      },
    );
  }
}

