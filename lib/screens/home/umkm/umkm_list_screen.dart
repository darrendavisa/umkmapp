import 'package:flutter/material.dart';

import '../../../models/paginated_result.dart';
import '../../../models/umkm_model.dart';
import '../../../services/api_service.dart';
import 'umkm_detail_screen.dart';

class UmkmListScreen extends StatefulWidget {
  const UmkmListScreen({super.key});

  @override
  State<UmkmListScreen> createState() => _UmkmListScreenState();
}

class _UmkmListScreenState extends State<UmkmListScreen> {
  final _apiService = ApiService();
  late Future<PaginatedResult<Umkm>> _futureUmkm;

  @override
  void initState() {
    super.initState();
    _futureUmkm = _apiService.getUmkmList();
  }

  Future<void> _muatUlang() async {
    setState(() {
      _futureUmkm = _apiService.getUmkmList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua UMKM')),
      body: FutureBuilder<PaginatedResult<Umkm>>(
        future: _futureUmkm,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gagal memuat data: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _muatUlang, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final hasil = snapshot.data!;
          if (hasil.data.isEmpty) {
            return const Center(child: Text('Belum ada UMKM yang terdaftar'));
          }

          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView.builder(
              itemCount: hasil.data.length,
              itemBuilder: (context, i) {
                final umkm = hasil.data[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: umkm.punyaFoto
                        ? NetworkImage(ApiService.fotoUrl(umkm.foto))
                        : null,
                    child: umkm.punyaFoto ? null : Text(umkm.nama[0]),
                  ),
                  title: Text(umkm.nama),
                  subtitle: Text(umkm.alamat),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UmkmDetailScreen(umkmId: umkm.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}