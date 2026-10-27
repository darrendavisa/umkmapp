import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Membungkus flutter_secure_storage agar seluruh aplikasi mengakses token
/// lewat satu pintu — bukan memanggil FlutterSecureStorage() di banyak tempat.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_token';

  static Future<void> simpan(String token) => _storage.write(key: _key, value: token);
  static Future<String?> ambil() => _storage.read(key: _key);
  static Future<void> hapus() => _storage.delete(key: _key);
}