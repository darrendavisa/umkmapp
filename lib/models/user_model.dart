class User {
  final int id;
  final String nama;
  final String email;

  User({required this.id, required this.nama, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nama: json['nama'] as String,
      email: json['email'] as String,
    );
  }
}