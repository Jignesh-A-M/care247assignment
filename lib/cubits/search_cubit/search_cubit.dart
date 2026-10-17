import 'package:care247assignment/cubits/search_cubit/search_state.dart';
import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:care247assignment/repositories/search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository searchRepository;

  SearchCubit({required this.searchRepository}) : super(SearchState());

  Future<void> fetchListOfCustomers() async {
    emit(state.copyWith(status: CustomerSearchStatus.loading, errorMessage: ''));
    try {
      final customers = await searchRepository.fetchListOfCustomers();
      emit(
        state.copyWith(
          customers: customers,
          filterCustomers: customers,
          status: customers.isEmpty ? CustomerSearchStatus.empty : CustomerSearchStatus.success,
          successMessage: 'Data fetched successfully',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), status: CustomerSearchStatus.error));
    }
  }

  Future<void> searchCustomers(Map<String, dynamic> filters) async {
    if (state.status == CustomerSearchStatus.loading) return;
    emit(state.copyWith(status: CustomerSearchStatus.loading, errorMessage: ''));
    try {
      final allCustomers = await searchRepository.fetchListOfCustomers();
      final customers = searchRepository.filterCustomers(allCustomers, filters);
      emit(
        state.copyWith(
          filterCustomers: customers,
          filters: filters,
          successMessage: 'Data fetched successfully',
          errorMessage: '',
          status: customers.isEmpty ? CustomerSearchStatus.empty : CustomerSearchStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerSearchStatus.error,
          errorMessage: 'Could not load customers. Please try again.',
          customers: [],
          filterCustomers: [],
        ),
      );
    }
  }

  /// Pull-to-refresh: re-request, keep the current criteria and the visible list.
  Future<void> refreshCustomers() async {
    if (state.isLoading) return;
    await searchCustomers(state.filters);
  }

  Future<void> toggleSearch({required bool isToggleSearch}) async {
    emit(state.copyWith(isShowSearchOption: isToggleSearch));
  }

  Future<void> clearSearch() async {
    List<CustomerModel> allCustomers = List.from(state.customers);
    emit(
      state.copyWith(
        filterCustomers: state.customers,
        status: allCustomers.isNotEmpty ? CustomerSearchStatus.success : state.status,
        errorMessage: '',
        filters: const {},
      ),
    );
  }
}
