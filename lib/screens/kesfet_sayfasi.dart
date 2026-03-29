import 'package:flutter/material.dart';

class KesfetSayfasi extends StatelessWidget {
  const KesfetSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Keşfet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.deepPurpleAccent.shade700, centerTitle: true, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 80, color: Colors.amber.shade500),
            const SizedBox(height: 20),
            const Text("Yapım Aşamasında 🚧", style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("SorBi'nin devasa Arama ve Keşfetme motoru\nyakında buraya eklenecektir.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
