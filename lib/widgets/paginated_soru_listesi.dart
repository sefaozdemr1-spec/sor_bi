import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';

class PaginatedSoruListesi extends StatefulWidget {
  final Query baseQuery;
  final String emptyMessage;

  const PaginatedSoruListesi({
    super.key, 
    required this.baseQuery, 
    this.emptyMessage = "Burada henüz soru yok...",
  });

  @override
  State<PaginatedSoruListesi> createState() => _PaginatedSoruListesiState();
}

class _PaginatedSoruListesiState extends State<PaginatedSoruListesi> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _docs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoading && _hasMore) {
        _fetchMoreData();
      }
    }
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isFirstLoad = true);
    
    try {
      final snapshot = await widget.baseQuery.limit(10).get();
      if (snapshot.docs.length < 10) _hasMore = false;
      _docs = snapshot.docs;
    } catch (e) {
      debugPrint("❌ Pagination Hatası: $e");
    } finally {
      if (mounted) setState(() => _isFirstLoad = false);
    }
  }

  Future<void> _fetchMoreData() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await widget.baseQuery
          .startAfterDocument(_docs.last)
          .limit(10)
          .get();

      if (snapshot.docs.length < 10) _hasMore = false;
      
      if (mounted) {
        setState(() {
          _docs.addAll(snapshot.docs);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Daha Fazla Getir Hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLoad) {
      return _buildShimmerSkeleton();
    }

    if (_docs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      color: Colors.pinkAccent,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _docs.length + 1,
        padding: const EdgeInsets.only(top: 10, bottom: 100),
        itemBuilder: (context, index) {
          if (index == _docs.length) {
            return _hasMore 
              ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 2)))
              : const SizedBox(height: 50);
          }
          final data = _docs[index].data() as Map<String, dynamic>;
          final soru = SoruModel.fromMap(_docs[index].id, data);
          return SoruKarti(soru: soru);
        },
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 60, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(widget.emptyMessage, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
