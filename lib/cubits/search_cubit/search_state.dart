import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:equatable/equatable.dart';

enum CustomerSearchStatus { initial, loading, success, empty, error }

class SearchState extends Equatable {
  final String errorMessage;
  final String successMessage;
  final List<CustomerModel> customers;
  final List<CustomerModel> filterCustomers;
  final CustomerSearchStatus status;
  final Map<String, dynamic> filters;
  final bool isShowSearchOption;

  const SearchState({
    this.errorMessage = '',
    this.successMessage = '',
    this.customers = const [],
    this.filterCustomers = const [],
    this.filters = const {},
    this.status = CustomerSearchStatus.initial,
    this.isShowSearchOption = false,
  });

  bool get isLoading => status == CustomerSearchStatus.loading;

  SearchState copyWith({
    String? errorMessage,
    String? successMessage,
    List<CustomerModel>? customers,
    List<CustomerModel>? filterCustomers,
    Map<String, dynamic>? filters,
    CustomerSearchStatus? status,
    bool? isShowSearchOption,
  }) {
    return SearchState(
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      customers: customers ?? this.customers,
      filterCustomers: filterCustomers ?? this.filterCustomers,
      filters: filters ?? this.filters,
      status: status ?? this.status,
      isShowSearchOption: isShowSearchOption ?? this.isShowSearchOption,
    );
  }

  @override
  List<Object?> get props => [
    errorMessage,
    successMessage,
    customers,
    filterCustomers,
    filters,
    status,
    isShowSearchOption,
  ];
}
