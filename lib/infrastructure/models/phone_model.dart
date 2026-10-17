class PhoneModel {
  final String id;
  final String type;
  final String number;
  final bool isPrimary;

  const PhoneModel({
    required this.id,
    required this.type,
    required this.number,
    required this.isPrimary,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'],
      type: json['type'],
      number: json['number'],
      isPrimary: json['isPrimary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'number': number, 'isPrimary': isPrimary};
  }
}
