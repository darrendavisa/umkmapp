import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/umkm_model.dart';
import '../models/produk_model.dart';
import '../models/paginated_result.dart';
import '../models/user_model.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'http://10.255.18.171:8080/api';

  Future<PaginatedResult<Umkm>> getUmkmList({String q = '', int page = 1}) async {
    final uri = Uri.parse('$baseUrl/umkm').replace(queryParameters: {
      if (q.isNotEmpty) 'q': q,
      'page': '$page',
      'limit': '10',
    });

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memuat data UMKM');
    }
    return PaginatedResult.fromJson(body, Umkm.fromJson);
  }

  Future<Umkm> getUmkmDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/umkm/$id'));
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'UMKM tidak ditemukan');
    }
    return Umkm.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<PaginatedResult<Produk>> getProdukByUmkm(int umkmId, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/umkm/$umkmId/produk').replace(queryParameters: {
      'page': '$page',
      'limit': '10',
    });

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memuat produk');
    }
    return PaginatedResult.fromJson(body, Produk.fromJson);
  }

  /// Header Authorization yang disisipkan ke setiap request yang butuh login.
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.ambil();
    return {'Authorization': 'Bearer $token'};
  }

  Future<User> register(String nama, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw ApiException(body['error']?['message'] ?? 'Gagal mendaftar');
    }
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Email atau password salah');
    }
    final token = body['data']['token'] as String;
    await TokenStorage.simpan(token);
  }

  Future<void> logout() => TokenStorage.hapus();

  Future<User> getProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/profile'), headers: await _authHeaders());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memuat profil');
    }
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> updateProfile(String nama, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {...await _authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memperbarui profil');
    }
  }

  Future<void> updatePassword(String lama, String baru) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/password'),
      headers: {...await _authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'password_lama': lama, 'password_baru': baru}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memperbarui password');
    }
  }

  Future<Umkm?> getUmkmSaya() async {
    final response = await http.get(Uri.parse('$baseUrl/umkm/saya'), headers: await _authHeaders());
    if (response.statusCode == 404) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal memuat UMKM saya');
    }
    return Umkm.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// id == null -> membuat UMKM baru (POST /umkm).
  /// id terisi -> mengubah UMKM yang sudah ada (PUT /umkm/{id}).
  Future<Umkm> simpanUmkm({
    int? id,
    required String nama,
    String deskripsi = '',
    String alamat = '',
    String? fotoPath,
  }) async {
    final uri = id == null ? Uri.parse('$baseUrl/umkm') : Uri.parse('$baseUrl/umkm/$id');
    final request = http.MultipartRequest(id == null ? 'POST' : 'PUT', uri)
      ..headers.addAll(await _authHeaders())
      ..fields['nama'] = nama
      ..fields['deskripsi'] = deskripsi
      ..fields['alamat'] = alamat;
    if (fotoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(body['error']?['message'] ?? 'Gagal menyimpan UMKM');
    }
    return Umkm.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> hapusUmkm(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/umkm/$id'), headers: await _authHeaders());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal menghapus UMKM');
    }
  }

  /// id == null -> tambah produk baru pada UMKM `umkmId` (POST /umkm/{umkmId}/produk).
  /// id terisi -> ubah produk yang sudah ada (PUT /produk/{id}), `umkmId` diabaikan.
  Future<Produk> simpanProduk({
    int? id,
    int? umkmId,
    required String nama,
    required double harga,
    String deskripsi = '',
    String? fotoPath,
  }) async {
    final uri = id == null
        ? Uri.parse('$baseUrl/umkm/$umkmId/produk')
        : Uri.parse('$baseUrl/produk/$id');
    final request = http.MultipartRequest(id == null ? 'POST' : 'PUT', uri)
      ..headers.addAll(await _authHeaders())
      ..fields['nama'] = nama
      ..fields['harga'] = '$harga'
      ..fields['deskripsi'] = deskripsi;
    if (fotoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(body['error']?['message'] ?? 'Gagal menyimpan produk');
    }
    return Produk.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> hapusProduk(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/produk/$id'), headers: await _authHeaders());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(body['error']?['message'] ?? 'Gagal menghapus produk');
    }
  }

  static String fotoUrl(String relativePath) {
    final origin = baseUrl.replaceFirst('/api', '');
    return '$origin/uploads/$relativePath';
  }
}