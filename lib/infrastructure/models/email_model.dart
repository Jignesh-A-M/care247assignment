class EmailModel {
  final String id;
  final String type;
  final String address;
  final bool isPrimary;

  const EmailModel({
    required this.id,
    required this.type,
    required this.address,
    required this.isPrimary,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id'],
      type: json['type'],
      address: json['address'],
      isPrimary: json['isPrimary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'address': address, 'isPrimary': isPrimary};
  }
}
