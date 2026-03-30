import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_servisi.dart';
import 'ana_sayfa_root.dart';

class DogrulamaBeklemeSayfasi extends StatefulWidget {
  const DogrulamaBeklemeSayfasi({super.key});

  @override
  State<DogrulamaBeklemeSayfasi> createState() => _DogrulamaBeklemeSayfasiState();
}

class _DogrulamaBeklemeSayfasiState extends State<DogrulamaBeklemeSayfasi> {
  bool _isChecking = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
       // verified, main.dart's builder will catch it
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Henüz onaylanmamış! Lütfen mail kutunuzu kontrol edin."), backgroundColor: Colors.orange),
         );
       }
    }
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded, size: 80, color: Colors.pinkAccent),
              const SizedBox(height: 24),
              const Text("Gmail Onayı Bekleniyor", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              const Text(
                "Lütfen Gmail kutunuza gönderdiğimiz doğrulama linkine tıklayarak hesabınızı onaylayın. Onayladıktan sonra aşağıdaki butona basın.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isChecking 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Onayladım, Kontrol Et!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Doğrulama maili tekrar gönderildi!")));
                  }
                },
                child: const Text("Maili Tekrar Gönder", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () => AuthServisi().cikisYap(),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text("Giriş Sayfasına Dön"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
