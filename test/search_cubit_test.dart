import 'dart:async';

import 'package:care247assignment/cubits/search_cubit/search_cubit.dart';
import 'package:care247assignment/cubits/search_cubit/search_state.dart';
import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:care247assignment/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'customer_model_test_data.dart';

// Fake repository: no network, the test decides what comes back.
class FakeSearchRepository extends SearchRepository {
  List<CustomerModel> customersToReturn = [];
  bool shouldFail = false;
  int callCount = 0;
  Completer<List<CustomerModel>>? waitFor;

  @override
  Future<List<CustomerModel>> fetchListOfCustomers() async {
    callCount++;
    if (waitFor != null) {
      return waitFor!.future;
    }
    if (shouldFail) {
      throw Exception('Cannot reach the server.');
    }
    return customersToReturn;
  }
}

void main() {
  var john = sampleCustomer(id: '1', firstName: 'John');
  var jane = sampleCustomer(id: '2', firstName: 'Jane');

  late FakeSearchRepository repository;
  late SearchCubit cubit;
  late List<CustomerSearchStatus> statuses;

  setUp(() {
    repository = FakeSearchRepository();
    repository.customersToReturn = [john, jane];
    cubit = SearchCubit(searchRepository: repository);
    statuses = [];
    cubit.stream.listen((state) {
      statuses.add(state.status);
    });
  });

  tearDown(() {
    cubit.close();
  });

  test('starts with initial status and no customers', () {
    expect(cubit.state.status, CustomerSearchStatus.initial);
    expect(cubit.state.customers, isEmpty);
    expect(cubit.state.filterCustomers, isEmpty);
  });

  test('fetchListOfCustomers goes loading then success', () async {
    await cubit.fetchListOfCustomers();
    await Future.delayed(Duration.zero);

    expect(statuses, [CustomerSearchStatus.loading, CustomerSearchStatus.success]);
    expect(cubit.state.customers.length, 2);
    expect(cubit.state.filterCustomers.length, 2);
  });

  test('fetchListOfCustomers with no data gives empty status', () async {
    repository.customersToReturn = [];

    await cubit.fetchListOfCustomers();

    expect(cubit.state.status, CustomerSearchStatus.empty);
  });

  test('fetchListOfCustomers failure gives error status', () async {
    repository.shouldFail = true;

    await cubit.fetchListOfCustomers();
    await Future.delayed(Duration.zero);

    expect(statuses, [CustomerSearchStatus.loading, CustomerSearchStatus.error]);
    expect(cubit.state.errorMessage, isNotEmpty);
  });

  test('searchCustomers shows only matching customers', () async {
    await cubit.searchCustomers({'firstName': 'jane'});

    expect(cubit.state.status, CustomerSearchStatus.success);
    expect(cubit.state.filterCustomers.length, 1);
    expect(cubit.state.filterCustomers.first, jane);
    expect(cubit.state.filters, {'firstName': 'jane'});
  });

  test('searchCustomers with no match gives empty status', () async {
    await cubit.searchCustomers({'firstName': 'zzz'});

    expect(cubit.state.status, CustomerSearchStatus.empty);
    expect(cubit.state.filterCustomers, isEmpty);
  });

  test('searchCustomers failure gives error status', () async {
    repository.shouldFail = true;

    await cubit.searchCustomers({'firstName': 'jane'});

    expect(cubit.state.status, CustomerSearchStatus.error);
    expect(cubit.state.errorMessage, isNotEmpty);
  });

  test('second search while the first is running does not call the api again', () async {
    repository.waitFor = Completer<List<CustomerModel>>();

    var firstSearch = cubit.searchCustomers({});
    await cubit.searchCustomers({'firstName': 'john'});
    repository.waitFor!.complete([john]);
    await firstSearch;

    expect(repository.callCount, 1);
  });

  test('refreshCustomers calls the api again and keeps the filters', () async {
    await cubit.searchCustomers({'firstName': 'jane'});

    await cubit.refreshCustomers();

    expect(repository.callCount, 2);
    expect(cubit.state.filters, {'firstName': 'jane'});
    expect(cubit.state.filterCustomers.length, 1);
  });

  test('clearSearch shows all customers again without calling the api', () async {
    await cubit.fetchListOfCustomers();
    await cubit.searchCustomers({'firstName': 'jane'});
    var callsBeforeClear = repository.callCount;

    await cubit.clearSearch();

    expect(cubit.state.filterCustomers.length, 2);
    expect(cubit.state.filters, isEmpty);
    expect(repository.callCount, callsBeforeClear);
  });

  test('toggleSearch changes isShowSearchOption', () async {
    await cubit.toggleSearch(isToggleSearch: true);
    expect(cubit.state.isShowSearchOption, true);

    await cubit.toggleSearch(isToggleSearch: false);
    expect(cubit.state.isShowSearchOption, false);
  });
}
