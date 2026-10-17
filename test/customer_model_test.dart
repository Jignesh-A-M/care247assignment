import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'customer_model_test_data.dart';

void main() {
  group('CustomerModel', () {
    test('fromJson reads basic fields', () {
      var customer = CustomerModel.fromJson(sampleCustomerJson());

      expect(customer.id, '1');
      expect(customer.firstName, 'John');
      expect(customer.lastName, 'Smith');
      expect(customer.dateOfBirth, '1985-03-15');
      expect(customer.maritalStatus, 'married');
      expect(customer.secureId, 'SEC-1');
    });

    test('fromJson reads addresses, phones and emails', () {
      var customer = CustomerModel.fromJson(sampleCustomerJson());

      expect(customer.addresses.length, 1);
      expect(customer.addresses.first.city, 'Austin');
      expect(customer.phones.length, 2);
      expect(customer.emails.length, 1);
      expect(customer.emails.first.address, 'user1@example.com');
    });

    test('fullName joins first name and last name', () {
      var customer = sampleCustomer(firstName: 'Ada', lastName: 'Lovelace');

      expect(customer.fullName, 'Ada Lovelace');
    });

    test('primaryPhone and primaryEmail return the primary entries', () {
      var customer = sampleCustomer();

      expect(customer.primaryPhone?.number, '555-0199');
      expect(customer.primaryEmail?.address, 'user1@example.com');
    });

    test('primaryPhone is null when no phone is primary', () {
      var json = sampleCustomerJson();
      json['phones'] = [
        {'id': 'p1', 'type': 'home', 'number': '555-0100', 'isPrimary': false},
      ];
      var customer = CustomerModel.fromJson(json);

      expect(customer.primaryPhone, isNull);
    });

    test('empty phones, emails and addresses are allowed', () {
      var json = sampleCustomerJson();
      json['phones'] = [];
      json['emails'] = [];
      json['addresses'] = [];
      var customer = CustomerModel.fromJson(json);

      expect(customer.phones, isEmpty);
      expect(customer.emails, isEmpty);
      expect(customer.addresses, isEmpty);
      expect(customer.primaryEmail, isNull);
    });

    test('fromJson throws when a required field is missing', () {
      var json = sampleCustomerJson();
      json.remove('firstName');

      expect(() => CustomerModel.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('toJson gives back the same data', () {
      var json = sampleCustomerJson();
      var customer = CustomerModel.fromJson(json);

      expect(customer.toJson(), json);
    });
  });
}
