import 'dart:async';

import 'package:base_pagination/base_pagination.dart';
import 'package:base_pagination/bloc/pagination_bloc.dart';
import 'package:example/bloc/user_bloc.dart';
import 'package:example/domain/user_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  runApp(const PaginationExample());
}

class PaginationExample extends StatelessWidget {
  const PaginationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<PaginationBloc<UserEntity>>(
        create: (_) => UserBloc()..add(PaginationFetch()),
        child: const PaginationScreen(),
      ),
    );
  }
}

class PaginationScreen extends StatelessWidget {
  const PaginationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Pagination<UserEntity>(
        errorBuilder: (context) => const Center(child: Text('error')),
        placeholderBuilder: (context, _) => const Center(child: Text('loading')),
        itemBuilder: (_, user) => Stack(
          fit: StackFit.expand,
          children: [
            Image.network(user.picture, fit: BoxFit.cover),
            Positioned.fill(child: Text(user.firstName)),
          ],
        ),
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        loader: const Padding(
          padding: EdgeInsets.all(30),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
