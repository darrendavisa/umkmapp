import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/produk_model.dart';
import '../../../services/api_service.dart';

class ProdukFormScreen extends StatefulWidget {
  final int umkmId;
  final Produk? produk; // null = tambah baru, terisi = mode edit
  const ProdukFormScreen({super.key, required this.umkmId, this.produk});
  @override
  State<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends State<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late final _namaController = TextEditingController(text: widget.produk?.nama ?? '');
  late final _hargaController = TextEditingController(text: widget.produk?.harga.toStringAsFixed(0) ?? '');
  late final _deskripsiController = TextEditingController(text: widget.produk?.deskripsi ?? '');
  XFile? _fotoBaru;
  bool _saving = false;

  Future<void> _pilihFoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _fotoBaru = file);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _apiService.simpanProduk(
        id: widget.produk?.id,
        umkmId: widget.umkmId,
        nama: _namaController.text,
        harga: double.parse(_hargaController.text),
        deskripsi: _deskripsiController.text,
        fotoPath: _fotoBaru?.path,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedangEdit = widget.produk != null;
    return Scaffold(
      appBar: AppBar(title: Text(sedangEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GestureDetector(
              onTap: _pilihFoto,
              child: _fotoBaru != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_fotoBaru!.path), height: 140, fit: BoxFit.cover))
                  : (sedangEdit && widget.produk!.foto.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(ApiService.fotoUrl(widget.produk!.foto), height: 140, fit: BoxFit.cover))
                      : Container(
                          height: 140,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.add_a_photo_outlined, size: 32)),
                        )),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Harga wajib diisi';
                if (double.tryParse(v) == null) return 'Harga harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _simpan,
                child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}