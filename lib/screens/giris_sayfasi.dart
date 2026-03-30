import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ana_sayfa_root.dart';
import '../main.dart'; // themeNotifier

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _isLoading = false;

  void _girisYap() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ TEMA TAKİBİ: Mürdüm mü Gündüz mü?
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
                  ? [const Color(0xFF0F0F12), const Color(0xFF2C0B4F)] // Gece Mürdüm
                  : [const Color(0xFFF7F8FA), Colors.white], // Gündüz İnci
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 💎 LOGO
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

                  // ✉️ INPUTLAR
                  _buildInput(_emailController, Icons.email_outlined, "E-posta", isDark),
                  const SizedBox(height: 16),
                  _buildInput(_sifreController, Icons.lock_outline_rounded, "Şifre", isDark, isPass: true),

                  const SizedBox(height: 40),

                  // 🚀 BUTONLAR
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
                  
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {}, 
                    child: Text("Hala üye değil misin? Hemen katıl!", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54)),
                  ),
                ],
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
}
