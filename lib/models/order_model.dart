import 'dart:convert';

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
    this.id = '',
    required this.userId,
    this.kasirId = '',
    required this.mejaId,
    required this.itemsJson,
    required this.totalHarga,
    this.status = 'Menunggu Konfirmasi',
    this.metodeBayar = 'Cash',
    this.catatan = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  // Getter helper untuk mendapatkan list item
  List<OrderItem> get items {
    try {
      final List decoded = json.decode(itemsJson);
      return decoded.map((i) => OrderItem.fromJson(i)).toList();
    } catch (e) {
      return [];
    }
  }

  // Getter helper untuk mendapatkan tanggal sebagai DateTime
  DateTime get tanggal {
    try {
      return DateTime.parse(createdAt);
    } catch (e) {
      return DateTime.now();
    }
  }

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

class OrderItem {
  final String menuId;
  final String nama;
  final int harga;
  final int quantity;
  final String size;

  OrderItem({
    required this.menuId,
    required this.nama,
    required this.harga,
    required this.quantity,
    required this.size,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuId: json['menuId']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      harga: json['harga'] is int ? json['harga'] : int.tryParse(json['harga'].toString()) ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      size: json['size']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'nama': nama,
      'harga': harga,
      'quantity': quantity,
      'size': size,
    };
  }
}
