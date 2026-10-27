class Produk {
  final int id;
  final int umkmId;
  final String nama;
  final double harga;
  final String deskripsi;
  final String foto;

  Produk({
    required this.id,
    required this.umkmId,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.foto,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as int,
      umkmId: json['umkm_id'] as int,
      nama: json['nama'] as String,
      harga: (json['harga'] as num).toDouble(),
      deskripsi: json['deskripsi'] as String? ?? '',
      foto: json['foto'] as String? ?? '',
    );
  }
}