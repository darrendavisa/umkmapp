class Umkm {
  final int id;
  final int userId;
  final String nama;
  final String deskripsi;
  final String alamat;
  final String foto;

  Umkm({
    required this.id,
    required this.userId,
    required this.nama,
    required this.deskripsi,
    required this.alamat,
    required this.foto,
  });

  factory Umkm.fromJson(Map<String, dynamic> json) {
    return Umkm(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      foto: json['foto'] as String? ?? '',
    );
  }

  bool get punyaFoto => foto.isNotEmpty;
}