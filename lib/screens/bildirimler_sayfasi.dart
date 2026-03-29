import 'package:flutter/material.dart';

class BildirimlerSayfasi extends StatelessWidget {
  const BildirimlerSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.deepPurpleAccent.shade700, centerTitle: true, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_rounded, size: 80, color: Colors.teal.shade200),
            const SizedBox(height: 20),
            const Text("Henüz Bildirim Yok 🔕", style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Ahali sorunu beğendiğinde veya\ncevapladığında radarlara burada düşecek.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
