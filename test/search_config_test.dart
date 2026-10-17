import 'package:care247assignment/infrastructure/config/search_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('searchConfig', () {
    test('has first name, last name, date of birth and marital status', () {
      var keys = searchConfig.map((field) => field.key).toList();

      expect(keys, contains('firstName'));
      expect(keys, contains('lastName'));
      expect(keys, contains('dateOfBirth'));
      expect(keys, contains('maritalStatus'));
    });

    test('field types are text, text and date', () {
      var firstName = searchConfig.firstWhere((field) => field.key == 'firstName');
      var lastName = searchConfig.firstWhere((field) => field.key == 'lastName');
      var dateOfBirth = searchConfig.firstWhere((field) => field.key == 'dateOfBirth');

      expect(firstName.type, FieldType.text);
      expect(lastName.type, FieldType.text);
      expect(dateOfBirth.type, FieldType.date);
    });

    test('keys are not repeated', () {
      var keys = searchConfig.map((field) => field.key).toSet();

      expect(keys.length, searchConfig.length);
    });

    test('render order is not repeated', () {
      var orders = searchConfig.map((field) => field.renderOrder).toSet();

      expect(orders.length, searchConfig.length);
    });

    test('sorting by renderOrder gives the form order', () {
      var sorted = [...searchConfig];
      sorted.sort((a, b) => a.renderOrder.compareTo(b.renderOrder));

      expect(sorted.map((field) => field.key).toList(), ['firstName', 'lastName', 'dateOfBirth', 'maritalStatus']);
    });
  });
}
