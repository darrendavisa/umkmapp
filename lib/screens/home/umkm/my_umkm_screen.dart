import 'package:flutter/material.dart';
import '../../../models/umkm_model.dart';
import '../../../models/produk_model.dart';
import '../../../models/paginated_result.dart';
import '../../../services/api_service.dart';
import 'umkm_form_screen.dart';
import 'produk_form_screen.dart';

class MyUmkmScreen extends StatefulWidget {
  const MyUmkmScreen({super.key});
  @override
  State<MyUmkmScreen> createState() => _MyUmkmScreenState();
}

class _MyUmkmScreenState extends State<MyUmkmScreen> {
  final _apiService = ApiService();
  late Future<Umkm?> _futureUmkm;
  int _produkKey = 0;

  @override
  void initState() {
    super.initState();
    _muatUmkm();
  }

  void _muatUmkm() {
    setState(() {
      _futureUmkm = _apiService.getUmkmSaya();
    });
  }

  void _muatUlangProduk() => setState(() => _produkKey++);

  Future<void> _bukaFormUmkm([Umkm? umkm]) async {
    final tersimpan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => UmkmFormScreen(umkm: umkm)),
    );
    if (tersimpan == true) _muatUmkm();
  }

  Future<void> _hapusUmkm(int id) async {
    try {
      await _apiService.hapusUmkm(id);
      _muatUmkm();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _bukaFormProduk(int umkmId, [Produk? produk]) async {
    final tersimpan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdukFormScreen(umkmId: umkmId, produk: produk)),
    );
    if (tersimpan == true) _muatUlangProduk();
  }

  Future<void> _hapusProduk(int id) async {
    try {
      await _apiService.hapusProduk(id);
      _muatUlangProduk();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UMKM Saya')),
      body: FutureBuilder<Umkm?>(
        future: _futureUmkm,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }
          final umkm = snapshot.data;
          if (umkm == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Anda belum memiliki UMKM'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => _bukaFormUmkm(), child: const Text('Buat UMKM')),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (umkm.punyaFoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(ApiService.fotoUrl(umkm.foto), height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(umkm.nama, style: Theme.of(context).textTheme.titleLarge),
              Text(umkm.alamat, style: TextStyle(color: Colors.grey[600])),
              Text(umkm.deskripsi),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => _bukaFormUmkm(umkm), child: const Text('Edit UMKM'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _hapusUmkm(umkm.id),
                      child: const Text('Hapus UMKM'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Produk', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () => _bukaFormProduk(umkm.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              _DaftarProduk(
                key: ValueKey(_produkKey),
                umkmId: umkm.id,
                apiService: _apiService,
                onEdit: (p) => _bukaFormProduk(umkm.id, p),
                onHapus: _hapusProduk,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget terpisah dengan state sendiri untuk daftar produk, supaya punya
/// siklus fetch-sekali-di-initState yang independen dari FutureBuilder UMKM
/// di atasnya (lihat catatan di bawah).
class _DaftarProduk extends StatefulWidget {
  final int umkmId;
  final ApiService apiService;
  final void Function(Produk) onEdit;
  final void Function(int id) onHapus;

  const _DaftarProduk({
    super.key,
    required this.umkmId,
    required this.apiService,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  State<_DaftarProduk> createState() => _DaftarProdukState();
}

class _DaftarProdukState extends State<_DaftarProduk> {
  late Future<PaginatedResult<Produk>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _futureProduk = widget.apiService.getProdukByUmkm(widget.umkmId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedResult<Produk>>(
      future: _futureProduk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Gagal memuat produk: ${snapshot.error}');
        }
        final produkList = snapshot.data!.data;
        if (produkList.isEmpty) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Belum ada produk'));
        }
        return Column(
          children: produkList.map((p) => ListTile(
            leading: p.foto.isNotEmpty
                ? CircleAvatar(backgroundImage: NetworkImage(ApiService.fotoUrl(p.foto)))
                : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
            title: Text(p.nama),
            subtitle: Text('Rp${p.harga.toStringAsFixed(0)}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') widget.onEdit(p);
                if (value == 'hapus') widget.onHapus(p.id);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'hapus', child: Text('Hapus')),
              ],
            ),
          )).toList(),
        );
      },
    );
  }
}