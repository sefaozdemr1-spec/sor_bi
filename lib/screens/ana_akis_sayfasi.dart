import 'package:flutter/material.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';

class AnaAkisSayfasi extends StatelessWidget {
  const AnaAkisSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'SorBi 🔥',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemCount: sahteSorular.length,
        itemBuilder: (context, index) {
          return SoruKarti(soru: sahteSorular[index]);
        },
      ),
    );
  }
}
