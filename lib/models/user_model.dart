class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String telepon;
  final String fotoUrl;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.telepon,
    required this.fotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      telepon: json['telepon']?.toString() ?? '',
      fotoUrl: json['foto_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'telepon': telepon,
      'foto_url': fotoUrl,
    };
  }
}
