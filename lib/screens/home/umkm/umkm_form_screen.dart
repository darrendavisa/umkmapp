import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/umkm_model.dart';
import '../../../services/api_service.dart';

class UmkmFormScreen extends StatefulWidget {
  final Umkm? umkm; // null = membuat baru, terisi = mode edit
  const UmkmFormScreen({super.key, this.umkm});
  @override
  State<UmkmFormScreen> createState() => _UmkmFormScreenState();
}

class _UmkmFormScreenState extends State<UmkmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late final _namaController = TextEditingController(text: widget.umkm?.nama ?? '');
  late final _deskripsiController = TextEditingController(text: widget.umkm?.deskripsi ?? '');
  late final _alamatController = TextEditingController(text: widget.umkm?.alamat ?? '');
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
      await _apiService.simpanUmkm(
        id: widget.umkm?.id,
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        alamat: _alamatController.text,
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
    final sedangEdit = widget.umkm != null;
    return Scaffold(
      appBar: AppBar(title: Text(sedangEdit ? 'Edit UMKM' : 'Buat UMKM')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GestureDetector(
              onTap: _pilihFoto,
              child: _fotoBaru != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_fotoBaru!.path), height: 160, fit: BoxFit.cover))
                  : (sedangEdit && widget.umkm!.punyaFoto
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(ApiService.fotoUrl(widget.umkm!.foto), height: 160, fit: BoxFit.cover))
                      : Container(
                          height: 160,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.add_a_photo_outlined, size: 32)),
                        )),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama UMKM', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
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
    _deskripsiController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}