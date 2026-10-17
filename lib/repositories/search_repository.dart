import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:care247assignment/infrastructure/config/app_config.dart';
import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:http/http.dart' as http;

class SearchRepository {
  const SearchRepository();

  Future<List<CustomerModel>> fetchListOfCustomers() async {
    final uri = Uri.parse(AppConfig.baseUrl);
    try {
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dynamic serverData = json.decode(response.body);
        if (serverData is List) {
          List<CustomerModel> customers = serverData.map((e) => CustomerModel.fromJson(e)).toList();
          return customers;
        }
        if (serverData is Map<String, dynamic>) {
          final data = serverData['data'];
          if (data == null) {
            return <CustomerModel>[];
          }
          if (data is List) {
            return data.map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e))).toList();
          }
          if (data is Map<String, dynamic>) {
            CustomerModel customer = CustomerModel.fromJson(Map<String, dynamic>.from(data));
            return [customer];
          }
        }
        throw Exception('Unexpected server response format');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Cannot reach the server. Check your connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  List<CustomerModel> filterCustomers(List<CustomerModel> customers, Map<String, dynamic> filters) {
    final criteria = <String, String>{};
    filters.forEach((key, value) {
      final text = value?.toString().trim().toLowerCase() ?? '';
      if (text.isNotEmpty) criteria[key] = text;
    });
    if (criteria.isEmpty) return customers;

    return customers.where((customer) {
      final customerJson = customer.toJson();
      return criteria.entries.every((entry) {
        final fieldValue = customerJson[entry.key]?.toString().toLowerCase() ?? '';
        return fieldValue.contains(entry.value);
      });
    }).toList();
  }
}
