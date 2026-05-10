class OrderModel {
  final String id;
  final String userId;
  final String kasirId;
  final String mejaId;
  final String itemsJson;
  final int totalHarga;
  final String status;
  final String metodeBayar;
  final String catatan;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.kasirId,
    required this.mejaId,
    required this.itemsJson,
    required this.totalHarga,
    required this.status,
    required this.metodeBayar,
    required this.catatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      kasirId: json['kasir_id']?.toString() ?? '',
      mejaId: json['meja_id']?.toString() ?? '',
      itemsJson: json['items_json']?.toString() ?? '[]',
      totalHarga: json['total_harga'] is int ? json['total_harga'] : int.tryParse(json['total_harga'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      metodeBayar: json['metode_bayar']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kasir_id': kasirId,
      'meja_id': mejaId,
      'items_json': itemsJson,
      'total_harga': totalHarga,
      'status': status,
      'metode_bayar': metodeBayar,
      'catatan': catatan,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
