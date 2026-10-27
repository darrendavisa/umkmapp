import 'package:flutter/material.dart';
import '../../../models/umkm_model.dart';
import '../../../models/produk_model.dart';
import '../../../models/paginated_result.dart';
import '../../../services/api_service.dart';

class UmkmDetailScreen extends StatefulWidget {
  final int umkmId;
  const UmkmDetailScreen({super.key, required this.umkmId});
  @override
  State<UmkmDetailScreen> createState() => _UmkmDetailScreenState();
}

class _UmkmDetailScreenState extends State<UmkmDetailScreen> {
  final _apiService = ApiService();
  late Future<Umkm> _futureUmkm;
  late Future<PaginatedResult<Produk>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _futureUmkm = _apiService.getUmkmDetail(widget.umkmId);
    _futureProduk = _apiService.getProdukByUmkm(widget.umkmId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail UMKM')),
      body: FutureBuilder<Umkm>(
        future: _futureUmkm,
        builder: (context, snapshotUmkm) {
          if (snapshotUmkm.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotUmkm.hasError) {
            return Center(child: Text('Gagal memuat UMKM: ${snapshotUmkm.error}'));
          }
          final umkm = snapshotUmkm.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (umkm.punyaFoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(ApiService.fotoUrl(umkm.foto), height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(umkm.nama, style: Theme.of(context).textTheme.titleLarge),
              Text(umkm.alamat, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(umkm.deskripsi),
              const Divider(height: 32),
              Text('Produk', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FutureBuilder<PaginatedResult<Produk>>(
                future: _futureProduk,
                builder: (context, snapshotProduk) {
                  if (snapshotProduk.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshotProduk.hasError) {
                    return Text('Gagal memuat produk: ${snapshotProduk.error}');
                  }
                  final produkList = snapshotProduk.data!.data;
                  if (produkList.isEmpty) {
                    return const Text('Belum ada produk');
                  }
                  return Column(
                    children: produkList.map((p) => ListTile(
                      leading: p.foto.isNotEmpty
                          ? CircleAvatar(backgroundImage: NetworkImage(ApiService.fotoUrl(p.foto)))
                          : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                      title: Text(p.nama),
                      subtitle: Text('Rp${p.harga.toStringAsFixed(0)}'),
                    )).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}