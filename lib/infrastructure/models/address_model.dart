class AddressModel {
  final String id;
  final String type;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const AddressModel({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      type: json['type'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}
