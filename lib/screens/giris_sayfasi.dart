import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/providers/auth_provider.dart';
import 'kayit_sayfasi.dart';
import '../main.dart'; // themeNotifier

class GirisSayfasi extends ConsumerStatefulWidget {
  const GirisSayfasi({super.key});

  @override
  ConsumerState<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends ConsumerState<GirisSayfasi> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _isLoading = false;

  void _girisYap() async {
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServisiProvider).girisYap(
        email: _emailController.text.trim(),
        sifre: _sifreController.text.trim(),
      );
      // Başarılı girişte _AuthSwitch otomatik olarak AnaSayfaRoot'a geçirecektir.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String mesaj = "Giriş yapılamadı.";
        if (e.code == 'user-not-found') mesaj = "Kullanıcı bulunamadı.";
        else if (e.code == 'wrong-password') mesaj = "Hatalı şifre.";
        else if (e.code == 'invalid-email') mesaj = "Geçersiz e-posta.";
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $mesaj"), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Beklenmedik hata: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF0F0F12), const Color(0xFF2C0B4F)] 
                  : [const Color(0xFFF7F8FA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView( // 🚀 Sayfa artık kaydırılabilir, taşma yapmaz!
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.deepPurpleAccent.withOpacity(0.05),
                      border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 80, color: Colors.pinkAccent),
                  ),
                  const SizedBox(height: 24),
                  Text("SorBi", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -2)),
                  const Text("Sorun, Bilin, Parlayın ✨", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  
                  const SizedBox(height: 60),

                  _buildInput(_emailController, Icons.email_outlined, "E-posta", isDark),
                  const SizedBox(height: 16),
                  _buildInput(_sifreController, Icons.lock_outline_rounded, "Şifre", isDark, isPass: true),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        shadowColor: Colors.pinkAccent.withOpacity(0.5),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // 🚀 HIZLI GİRİŞ VE SOSYAL GİRİŞLER
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          // 🏁 1. ŞANS: Anonim Giriş Dene
                          await FirebaseAuth.instance.signInAnonymously();
                        } catch (_) {
                          // 🏁 2. ŞANS: Test Hesabı ile Giriş Dene
                          try {
                            await ref.read(authServisiProvider).girisYap(
                              email: 'test@sorbi.com',
                              sifre: '12345678',
                            );
                          } catch (err) {
                            // 🏁 3. ŞANS (KESİN ÇÖZÜM): Test Hesabını Hemen OLUŞTUR ve GİR!
                            try {
                              await ref.read(authServisiProvider).kayitOl(
                                email: 'test@sorbi.com',
                                sifre: '12345678',
                                kullaniciAdi: 'SorBiliyo Üyesi (Test)',
                              );
                            } catch (eFinal) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 En yakın sürede sistem açılacak, lütfen Google ile girmeyi deneyin!")));
                            }
                          }
                        }
                        setState(() => _isLoading = false);
                      },
                      icon: const Icon(Icons.bolt_rounded, color: Colors.amberAccent),
                      label: const Text("HIZLI GİRİŞ (Zırhlı Mod)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(children: [ Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("VEYA", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))), Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)) ] ),
                  const SizedBox(height: 30),

                  // 🌐 SOSYAL GİRİŞLER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(Icons.g_mobiledata_rounded, Colors.redAccent, "Google", () => ref.read(authServisiProvider).googleIleGiris()),
                      const SizedBox(width: 20),
                      _socialButton(Icons.apple_rounded, isDark ? Colors.white : Colors.black87, "Apple", () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KayitSayfasi())),
                    child: Text("Hala üye değil misin? Hemen katıl!", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildInput(TextEditingController ctrl, IconData icon, String hint, bool isDark, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        onSubmitted: (_) => _girisYap(), // Klavyeden enter ile giriş desteği
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black38),
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 30),
        tooltip: tooltip,
        onPressed: onTap,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

