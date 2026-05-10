class MenuModel {
  final String id;
  final String nama;
  final String deskripsi;
  final int harga;
  final String kategori;
  final String gambarUrl;
  final bool statusAktif;

  MenuModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.gambarUrl,
    required this.statusAktif,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      harga: json['harga'] is int ? json['harga'] : int.tryParse(json['harga'].toString()) ?? 0,
      kategori: json['kategori']?.toString() ?? '',
      gambarUrl: json['gambar_url']?.toString() ?? '',
      statusAktif: json['status_aktif'] == true || json['status_aktif'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'gambar_url': gambarUrl,
      'status_aktif': statusAktif,
    };
  }
}
