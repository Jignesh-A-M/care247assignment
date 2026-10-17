import 'package:care247assignment/infrastructure/models/email_model.dart';
import 'package:care247assignment/infrastructure/models/phone_model.dart';

import 'address_model.dart';

class CustomerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String maritalStatus;
  final String secureId;
  final List<AddressModel> addresses;
  final List<PhoneModel> phones;
  final List<EmailModel> emails;

  const CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.secureId,
    required this.addresses,
    required this.phones,
    required this.emails,
  });

  CustomerModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? maritalStatus,
    String? secureId,
    List<AddressModel>? addresses,
    List<PhoneModel>? phones,
    List<EmailModel>? emails,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      secureId: secureId ?? this.secureId,
      addresses: addresses ?? this.addresses,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      maritalStatus: json['maritalStatus'],
      secureId: json['secureId'],
      addresses: List<AddressModel>.from(json['addresses'].map((data) => AddressModel.fromJson(data))),
      phones: List<PhoneModel>.from(json['phones'].map((data) => PhoneModel.fromJson(data))),
      emails: List<EmailModel>.from(json['emails'].map((data) => EmailModel.fromJson(data))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'secureId': secureId,
      'addresses': addresses.map((data) => data.toJson()).toList(),
      'phones': phones.map((data) => data.toJson()).toList(),
      'emails': emails.map((data) => data.toJson()).toList(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  PhoneModel? get primaryPhone {
    for (final phone in phones) {
      if (phone.isPrimary) return phone;
    }
    return null;
  }

  EmailModel? get primaryEmail {
    for (final email in emails) {
      if (email.isPrimary) return email;
    }
    return null;
  }
}
