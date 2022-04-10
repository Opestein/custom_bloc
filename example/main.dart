/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2022. All rights reserved.
    */

import 'dart:async';

import 'package:custom_bloc/custom_bloc.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: Example(),
  ));
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomStreamBuilder<int, String>(
              stream: counterBloc.behaviorSubject,
              dataBuilder: (context, data) {
                return ListView.separated(
                  itemCount: 1,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$index',
                              style: const TextStyle(),
                            ),
                          ],
                        ));
                  },
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: VerticalDivider(),
                    );
                  },
                );
              },
              loadingBuilder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error) => Text(
                error,
                style: const TextStyle(),
              ),
            ),
          ),
          const SizedBox(
            height: 34,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    counterBloc.fetchCurrent(false);
                  },
                  child: const Text(
                    'Add Value',
                    style: TextStyle(),
                  )),
              const SizedBox(
                width: 34,
              ),
              TextButton(
                  onPressed: () {
                    counterBloc.fetchCurrent(true);
                  },
                  child: const Text(
                    'Add Error',
                    style: TextStyle(),
                  )),
            ],
          ),
          const SizedBox(
            height: 34,
          )
        ],
      ),
    );
  }
}

class CounterBloc with BaseBloc<int, String> {
  int value = 0;

  CounterBloc() {
    fetchCurrent(false);
  }

  fetchCurrent(bool addError) async {
    setAsLoading();

    if (!addError) {
      await Future.delayed(const Duration(seconds: 2));
      value++;
      addToModel(value);
    } else {
      value = 0;
      addToError('Could not fetch data');
    }
  }

  invalidate() {
    invalidateBaseBloc();
  }

  dispose() {
    disposeBaseBloc();
  }
}
