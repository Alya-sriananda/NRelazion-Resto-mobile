class CartItem {
  final String id;
  final String menuId;
  final String nama;
  final int harga;
  final String gambarUrl;
  String size;
  int quantity;

  CartItem({
    required this.id,
    required this.menuId,
    required this.nama,
    required this.harga,
    required this.gambarUrl,
    required this.size,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuId': menuId,
    'nama': nama,
    'harga': harga,
    'gambarUrl': gambarUrl,
    'size': size,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    menuId: json['menuId'],
    nama: json['nama'],
    harga: json['harga'],
    gambarUrl: json['gambarUrl'],
    size: json['size'],
    quantity: json['quantity'],
  );
}
