class MejaModel {
  final String id;
  final String area;
  final String nomor;
  final int kapasitas;
  final String status;

  MejaModel({
    required this.id,
    required this.area,
    required this.nomor,
    required this.kapasitas,
    required this.status,
  });

  factory MejaModel.fromJson(Map<String, dynamic> json) {
    return MejaModel(
      id: json['id']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      nomor: json['nomor']?.toString() ?? '',
      kapasitas: json['kapasitas'] is int ? json['kapasitas'] : int.tryParse(json['kapasitas'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'Tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area': area,
      'nomor': nomor,
      'kapasitas': kapasitas,
      'status': status,
    };
  }
}
