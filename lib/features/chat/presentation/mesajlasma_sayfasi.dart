import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/mesaj_servisi.dart';
import '../controllers/chat_controller.dart';
import 'dart:ui';

class MesajlasmaSayfasi extends StatefulWidget {
  final String chatId;
  final String hedefIsim;
  final String hedefFoto;
  final String hedefUid;

  const MesajlasmaSayfasi({
    super.key,
    required this.chatId,
    required this.hedefIsim,
    required this.hedefFoto,
    required this.hedefUid,
  });

  @override
  State<MesajlasmaSayfasi> createState() => _MesajlasmaSayfasiState();
}

class _MesajlasmaSayfasiState extends State<MesajlasmaSayfasi> {
  final _mesajController = TextEditingController();
  final _mesajServisi = MesajServisi();
  final _chatController = ChatController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mesajServisi.mesajOkunduisaretle(widget.chatId);
  }

  void _mesajGonder() async {
    final metin = _mesajController.text.trim();
    if (metin.isEmpty) return;
    _mesajController.clear();
    _chatController.typingDurumuGuncelle(widget.chatId, "");
    await _mesajServisi.mesajGonderV3(widget.chatId, metin);
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final suankiUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.8),
        flexibleSpace: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.transparent))),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
          builder: (context, snapshot) {
            bool isTyping = false;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              isTyping = data['typing']?[widget.hedefUid] == true;
            }
            return Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(widget.hedefFoto), radius: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.hedefIsim, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                    if (isTyping)
                      const Text("yazıyor...", style: TextStyle(fontSize: 10, color: Colors.pinkAccent, fontWeight: FontWeight.w600))
                    else 
                      const Text("çevrimiçi", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            );
          }
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFF7F8FA), Colors.pinkAccent.withOpacity(0.02)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _mesajServisi.mesajlariGetir(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                     return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.red, fontSize: 12)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: CircularProgressIndicator());
                  }
                  
                  final mesajlar = snapshot.data?.docs ?? [];
                  
                  if (mesajlar.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          const Text("Henüz mesaj yok,\nilk selamı sen ver! 👋", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
                    builder: (context, chatSnap) {
                      Timestamp? lastReadOther;
                      if (chatSnap.hasData && chatSnap.data!.exists) {
                        lastReadOther = (chatSnap.data!.data() as Map<String, dynamic>)['lastRead']?[widget.hedefUid] as Timestamp?;
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                        itemCount: mesajlar.length,
                        itemBuilder: (context, index) {
                          final m = mesajlar[index].data() as Map<String, dynamic>;
                          bool isMe = m['senderId'] == suankiUid;
                          bool isRead = isMe && lastReadOther != null && (m['createdAt'] as Timestamp).toDate().isBefore(lastReadOther.toDate());

                          return _buildSorBiBubble(m['text'] ?? '', isMe, isRead);
                        },
                      );
                    }
                  );
                },
              ),
            ),

            // ✍️ SorBi Özel Mesaj Kutusu (Unique Design)
            _buildCustomInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSorBiBubble(String text, bool isMe, bool isRead) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4, top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              gradient: isMe 
                ? const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF1F1F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isMe ? 24 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 24),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, height: 1.4)),
          ),
          if (isMe && isRead)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 10),
              child: Text("görüldü", style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _mesajController,
                onChanged: (val) => _chatController.typingDurumuGuncelle(widget.chatId, val),
                decoration: const InputDecoration(
                  hintText: 'Fikrini fısılda...', 
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.pinkAccent, Colors.deepPurpleAccent])),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white), 
              onPressed: _mesajGonder
            ),
          ),
        ],
      ),
    );
  }
}
