import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/providers/auth_provider.dart';
import 'eula_sayfasi.dart'; // Milyarlık Hukuk Sözleşmesi
import '../main.dart'; // 🎨 Tema takibi için gerekli import!
class KayitSayfasi extends ConsumerStatefulWidget {
  const KayitSayfasi({super.key});

  @override
  ConsumerState<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends ConsumerState<KayitSayfasi> {
  final _isimSecici = TextEditingController();
  final _emailSecici = TextEditingController();
  final _sifreSecici = TextEditingController();
  final _sifreTekrarSecici = TextEditingController(); 
  bool _isLoading = false;
  bool _sifreGoster = false; 
  bool _sifreTekrarGoster = false; 
  bool _eulaKabulEdildi = false;
  bool _acikRizaKabulEdildi = false;
  bool _pazarlamaKabulEdildi = false;

  void _sekreterKayit() async {
    // 1. KURAL: EULA Kabul Edilmediyse Kapıdan Sokma!
    if (!_eulaKabulEdildi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Lütfen Üyelik Sözleşmesi'ni (EULA) kabul ediniz."), backgroundColor: Colors.orange),
      );
      return;
    }
    // 2. KURAL: KVKK Açık Rıza Onayı Zorunlu!
    if (!_acikRizaKabulEdildi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Lütfen KVKK Açık Rıza Metnini kabul ediniz."), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_isimSecici.text.isEmpty || _emailSecici.text.isEmpty || _sifreSecici.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }
    
    // 3. KURAL: Şifreler Aynı Olmadan Kapı Açılmaz!
    if (_sifreSecici.text != _sifreTekrarSecici.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Girdiğiniz şifreler birbirleriyle uyuşmuyor!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_sifreSecici.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Şifreniz en az 8 karakter uzunluğunda olmalıdır."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🚀 Yeni AuthServisi ile Kayıt İşlemi
      await ref.read(authServisiProvider).kayitOl(
        email: _emailSecici.text.trim(),
        sifre: _sifreSecici.text.trim(),
        kullaniciAdi: _isimSecici.text.trim(),
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt Başarılı! ✅ SorBi dünyasına hoş geldin!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Giriş sayfasına veya Ana sayfaya döner
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String mesaj = "Kayıt sırasında bir hata oluştu.";
        if (e.code == 'email-already-in-use') mesaj = "Bu e-posta adresi zaten kullanımda.";
        else if (e.code == 'weak-password') mesaj = "Şifre çok zayıf.";
        else if (e.code == 'invalid-email') mesaj = "Geçersiz e-posta adresi.";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $mesaj"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Beklenmedik bir hata oluştu: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  void dispose() {
    _isimSecici.dispose();
    _emailSecici.dispose();
    _sifreSecici.dispose();
    _sifreTekrarSecici.dispose();
    super.dispose();
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
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF0F0F12), const Color(0xFF2C0B4F)] 
                  : [const Color(0xFFF7F8FA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // 💎 LOGO VE BAŞLIK
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.deepPurpleAccent.withOpacity(0.05),
                        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded, size: 60, color: Colors.pinkAccent),
                    ),
                    const SizedBox(height: 20),
                    Text("SorBi Üyesi Ol", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    const Text("Sorularını Keşfetmeye Hazır mısın? ✨", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    
                    const SizedBox(height: 40),

                    // ✉️ INPUTLAR
                    _buildInput(_isimSecici, Icons.badge_outlined, "Kullanıcı Adı", isDark),
                    const SizedBox(height: 16),
                    _buildInput(_emailSecici, Icons.email_outlined, "E-posta", isDark),
                    const SizedBox(height: 16),
                    _buildInput(_sifreSecici, Icons.lock_outline_rounded, "Şifre", isDark, isPass: true, passVar: _sifreGoster, onToggle: () => setState(() => _sifreGoster = !_sifreGoster)),
                    const SizedBox(height: 16),
                    _buildInput(_sifreTekrarSecici, Icons.verified_user_outlined, "Şifre Tekrar", isDark, isPass: true, passVar: _sifreTekrarGoster, onToggle: () => setState(() => _sifreTekrarGoster = !_sifreTekrarGoster)),

                    const SizedBox(height: 24),
                    
                    // CHECKBOXLAR
                    _checkboxSatiri(
                      deger: _eulaKabulEdildi,
                      renk: Colors.pinkAccent,
                      isDark: isDark,
                      onDegisti: (val) => setState(() => _eulaKabulEdildi = val ?? false),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EulaSayfasi())),
                      metin: "Üyelik Sözleşmesi ve Gizlilik Politikası'nı okudum.",
                    ),
                    const SizedBox(height: 8),
                    _checkboxSatiri(
                      deger: _acikRizaKabulEdildi,
                      renk: Colors.cyan,
                      isDark: isDark,
                      onDegisti: (val) => setState(() => _acikRizaKabulEdildi = val ?? false),
                      onTap: () => _acikRizaMetniGoster(context),
                      metin: "KVKK Açık Rıza Metni'ni okudum ve kabul ediyorum.",
                    ),

                    const SizedBox(height: 30),

                    // 🚀 KAYIT OL BUTONU
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sekreterKayit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 10,
                          shadowColor: Colors.pinkAccent.withOpacity(0.5),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text("Kayıt Ol ve Parlamaya Başla", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // GERİ DÖNÜŞ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Zaten bir hesabın var mı?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Giriş Yap", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(TextEditingController ctrl, IconData icon, String hint, bool isDark, {bool isPass = false, bool? passVar, VoidCallback? onToggle}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass ? !(passVar ?? false) : false,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black38),
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          suffixIcon: isPass ? IconButton(
            icon: Icon(passVar == true ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
            onPressed: onToggle,
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _checkboxSatiri({required bool deger, required Color renk, required bool isDark, required Function(bool?) onDegisti, required VoidCallback onTap, required String metin}) {
    return GestureDetector(
      onTap: () => onDegisti(!deger),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : renk.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: deger,
                onChanged: onDegisti,
                activeColor: renk,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metin, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black87)),
                  GestureDetector(
                    onTap: onTap,
                    child: Text("Sözleşmeyi Oku", style: TextStyle(fontSize: 11, color: renk, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KVKK Açık Rıza Metni (Aynı stil Modal)
  void _acikRizaMetniGoster(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.privacy_tip_rounded, color: Colors.cyan, size: 50),
            const SizedBox(height: 16),
            const Text("KVKK Açık Rıza", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Kişisel verilerinizin işlenmesine yönelik detaylı bilgilendirme... Buraya KVKK metni gelecek. SorBi ekibi verilerinizi sadece size daha iyi bir deneyim sunmak için kullanır.",
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _acikRizaKabulEdildi = true);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
                child: const Text("Okudum, Onaylıyorum"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
