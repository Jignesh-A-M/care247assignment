import 'package:care247assignment/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'customer_model_test_data.dart';


void main() {
  group('filterCustomers', () {
    var repository = const SearchRepository();
    var john = sampleCustomer(id: '1', firstName: 'John', lastName: 'Smith', dateOfBirth: '1985-03-15');
    var jane = sampleCustomer(
      id: '2',
      firstName: 'Jane',
      lastName: 'Smith',
      dateOfBirth: '1990-07-01',
      maritalStatus: 'single',
    );
    var joan = sampleCustomer(id: '3', firstName: 'Joan', lastName: 'Jones', dateOfBirth: '1985-03-15');
    var everyone = [john, jane, joan];

    test('no filters returns everyone', () {
      expect(repository.filterCustomers(everyone, {}).length, 3);
    });

    test('blank values are ignored', () {
      var result = repository.filterCustomers(everyone, {'firstName': '   ', 'lastName': ''});

      expect(result.length, 3);
    });

    test('matches part of the value and ignores upper or lower case', () {
      var result = repository.filterCustomers(everyone, {'firstName': 'jo'});

      expect(result.length, 2);
      expect(result.contains(john), true);
      expect(result.contains(joan), true);
    });

    test('matches date of birth', () {
      var result = repository.filterCustomers(everyone, {'dateOfBirth': '1990-07-01'});

      expect(result.length, 1);
      expect(result.first, jane);
    });

    test('all filters must match', () {
      var result = repository.filterCustomers(everyone, {'lastName': 'smith', 'dateOfBirth': '1985-03-15'});

      expect(result.length, 1);
      expect(result.first, john);
    });

    test('works for a field added later like maritalStatus', () {
      var result = repository.filterCustomers(everyone, {'maritalStatus': 'single'});

      expect(result.length, 1);
      expect(result.first, jane);
    });

    test('no match gives an empty list', () {
      var result = repository.filterCustomers(everyone, {'firstName': 'zzz'});

      expect(result, isEmpty);
    });
  });
}