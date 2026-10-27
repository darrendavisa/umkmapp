import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  late Future<User> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _apiService.getProfile();
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: FutureBuilder<User>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }
          final user = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(radius: 36, child: Text(user.nama[0].toUpperCase(), style: const TextStyle(fontSize: 28))),
              const SizedBox(height: 16),
              Text(user.nama, style: Theme.of(context).textTheme.titleLarge),
              Text(user.email, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Ubah Profil & Password'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateProfileScreen(user: user)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}