import 'package:care247assignment/infrastructure/models/customer_model.dart';

Map<String, dynamic> sampleCustomerJson({
  String id = '1',
  String firstName = 'John',
  String lastName = 'Smith',
  String dateOfBirth = '1985-03-15',
  String maritalStatus = 'married',
}) {
  return {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth,
    'maritalStatus': maritalStatus,
    'secureId': 'SEC-$id',
    'addresses': [
      {'id': 'a$id', 'type': 'home', 'street': '1 Main Street', 'city': 'Austin', 'state': 'TX', 'zipCode': '73301'},
    ],
    'phones': [
      {'id': 'p1$id', 'type': 'home', 'number': '555-0100', 'isPrimary': false},
      {'id': 'p2$id', 'type': 'mobile', 'number': '555-0199', 'isPrimary': true},
    ],
    'emails': [
      {'id': 'e$id', 'type': 'personal', 'address': 'user$id@example.com', 'isPrimary': true},
    ],
  };
}

CustomerModel sampleCustomer({
  String id = '1',
  String firstName = 'John',
  String lastName = 'Smith',
  String dateOfBirth = '1985-03-15',
  String maritalStatus = 'married',
}) {
  return CustomerModel.fromJson(
    sampleCustomerJson(
      id: id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      maritalStatus: maritalStatus,
    ),
  );
}