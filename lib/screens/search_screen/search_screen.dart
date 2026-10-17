import 'package:care247assignment/cubits/search_cubit/search_cubit.dart';
import 'package:care247assignment/cubits/search_cubit/search_state.dart';
import 'package:care247assignment/infrastructure/config/search_config.dart';
import 'package:care247assignment/screens/result_screen/new_result_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_textform_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<FieldConfig> configureFields = [...searchConfig]..sort((a, b) => a.renderOrder.compareTo(b.renderOrder));
  final Map<String, TextEditingController> searchControllers = {};
  final Map<String, FocusNode> searchFocusNodes = {};

  @override
  void initState() {
    for (var field in configureFields) {
      searchControllers[field.key] = TextEditingController();
      searchFocusNodes[field.key] = FocusNode();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (mounted) {
        var searchCubit = context.read<SearchCubit>();
        await searchCubit.fetchListOfCustomers();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in searchControllers.values) {
      controller.dispose();
    }
    for (final focusNode in searchFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void clearFields() {
    for (final controller in searchControllers.values) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var searchCubit = context.read<SearchCubit>();
    return BlocConsumer<SearchCubit, SearchState>(
      listenWhen: (previous, current) {
        bool a = previous.isShowSearchOption != current.isShowSearchOption;
        bool b = previous.errorMessage != current.errorMessage;
        return a || b;
      },
      listener: (context, state) {
        // clear all text fields
        if (state.isShowSearchOption == false) {
          clearFields();
          FocusScope.of(context).unfocus();
          if (!searchCubit.isClosed) {
            searchCubit.clearSearch();
          }
        }

        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            title: Text(
              'Search Customer',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xff801c8c),
            actions: [
              IconButton(
                onPressed: () {
                  // Toggle search option
                  searchCubit.toggleSearch(isToggleSearch: !state.isShowSearchOption);
                },
                icon: Icon(!state.isShowSearchOption ? Icons.search : Icons.close, color: Colors.white),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: state.isShowSearchOption
                  ? BorderRadius.zero
                  : BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(8)),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (state.isShowSearchOption) ...[
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      color: const Color(0xff801c8c),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          const SizedBox(height: 8),
                          ...List.generate(configureFields.length, (index) {
                            return SearchTextFormField(
                              config: configureFields[index],
                              controller: searchControllers[configureFields[index].key]!,
                              focusNode: searchFocusNodes[configureFields[index].key]!,
                              textInputAction: index == configureFields.length - 1
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              onSubmitted: () {
                                FocusScope.of(context).unfocus();
                                // move to focus next field
                                // check is Last or not
                                bool isLast = index == configureFields.length - 1;
                                if (!isLast) {
                                  searchFocusNodes[configureFields[index + 1].key]!.requestFocus();
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    // filter data
                                    await searchFilterData(searchCubit, context);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Color(0xfff58030)),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Search'),
                                ),
                              ),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xfff58030),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: const BorderSide(color: Colors.white, width: 1.0),
                                  ),
                                  onPressed: () {
                                    // clear all text fields and state.
                                    clearFields();
                                    FocusScope.of(context).unfocus();
                                    searchCubit.clearSearch();
                                  },
                                  child: const Text('Clear'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              BlocBuilder<SearchCubit, SearchState>(
                buildWhen: (previous, current) {
                  bool a = previous.customers != current.customers;
                  bool b = previous.status != current.status;
                  bool c = previous.filters != current.filters;
                  return a || b || c;
                },
                builder: (context, state) {
                  if (state.status == CustomerSearchStatus.loading) {
                    return Expanded(
                      child: Center(child: CupertinoActivityIndicator(radius: 20, color: Color(0xfff58030))),
                    );
                  }
                  if (state.filterCustomers.isEmpty) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("No customer found!!!"),
                          SizedBox(height: 8),
                          FilledButton.icon(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Color(0xfff58030)),
                              foregroundColor: WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            onPressed: () async {
                              if (state.customers.isEmpty) {
                                await searchCubit.fetchListOfCustomers();
                                return;
                              }
                              await searchFilterData(searchCubit, context);
                            },
                            label: Text("Retry"),
                            icon: Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }
                  return Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () async {
                        if (!searchCubit.isClosed) {
                          if (state.customers.isEmpty) {
                            await searchCubit.fetchListOfCustomers();
                            return;
                          }
                          await searchFilterData(searchCubit, context);
                          return;
                        }
                      },
                      color: Color(0xfff58030),
                      child: ListView.builder(
                        itemCount: state.filterCustomers.length,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                        addAutomaticKeepAlives: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        primary: true,
                        itemBuilder: (context, index) {
                          var theme = Theme.of(context);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NewResultScreen(customer: state.filterCustomers[index]);
                                    },
                                  ),
                                );
                              },
                              selectedColor: Color(0xff801c8c),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              tileColor: Colors.white,
                              isThreeLine: false,
                              splashColor: Colors.black,
                              titleTextStyle: theme.textTheme.titleMedium,
                              subtitleTextStyle: theme.textTheme.labelSmall,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: Text(state.filterCustomers[index].fullName),
                              subtitle: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("DOB : ${state.filterCustomers[index].dateOfBirth}"),
                                  Text(
                                    "Primary contact Info : ${state.filterCustomers[index].primaryPhone?.number ?? 'Not Provided'} || ${state.filterCustomers[index].primaryEmail?.address ?? 'Not Provided'}",
                                    style: TextStyle(color: Color(0xff801c8c)),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return NewResultScreen(customer: state.filterCustomers[index]);
                                      },
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xfff58030)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> searchFilterData(SearchCubit searchCubit, BuildContext context) async {
    // filter data
    Map<String, dynamic> filters = {};

    for (var filed in configureFields) {
      filters[filed.key] = searchControllers[filed.key]!.text;
    }

    await searchCubit.searchCustomers(filters);
    if (context.mounted) {
      FocusScope.of(context).unfocus();
    }
  }
}
