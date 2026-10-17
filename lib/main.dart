import 'package:care247assignment/cubits/search_cubit/search_cubit.dart';
import 'package:care247assignment/repositories/search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/search_screen/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchRepository(),
      child: BlocProvider(
        create: (context) =>
            SearchCubit(searchRepository: context.read<SearchRepository>()),
        child: MaterialApp(
          title: 'Care247 Flutter Assignment',
          debugShowCheckedModeBanner: false,
          home: const SearchScreen(),
        ),
      ),
    );
  }
}
