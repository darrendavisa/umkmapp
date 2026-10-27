import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;
  const UpdateProfileScreen({super.key, required this.user});
  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _apiService = ApiService();
  final _formProfilKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  late final _namaController = TextEditingController(text: widget.user.nama);
  late final _emailController = TextEditingController(text: widget.user.email);
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  bool _savingProfil = false;
  bool _savingPassword = false;

  Future<void> _simpanProfil() async {
    if (!_formProfilKey.currentState!.validate()) return;
    setState(() => _savingProfil = true);
    try {
      await _apiService.updateProfile(_namaController.text, _emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _savingProfil = false);
    }
  }

  Future<void> _simpanPassword() async {
    if (!_formPasswordKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    try {
      await _apiService.updatePassword(_passwordLamaController.text, _passwordBaruController.text);
      if (!mounted) return;
      _passwordLamaController.clear();
      _passwordBaruController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diperbarui')));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Profil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Form(
            key: _formProfilKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _savingProfil ? null : _simpanProfil,
                    child: Text(_savingProfil ? 'Menyimpan...' : 'Simpan Profil'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 48),
          Form(
            key: _formPasswordKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _passwordLamaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password Lama', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password lama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordBaruController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _savingPassword ? null : _simpanPassword,
                    child: Text(_savingPassword ? 'Menyimpan...' : 'Ubah Password'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    super.dispose();
  }
}