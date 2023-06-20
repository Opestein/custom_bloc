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
  String type = 'multi';
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: type == 'one'
        ? const Example()
        : type == 'two'
            ? const Example2()
            : const ExampleMulti(),
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
  void dispose() {
    super.dispose();
    counterBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomStreamBuilder<int, String>(
                stream: counterBloc.behaviorSubject,
                dataBuilder: (context, data) {
                  return ListView.separated(
                    itemCount: 1,
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'index: $index: data: $data',
                                style: const TextStyle(fontSize: 34),
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
                      counterBloc.resetData();
                    },
                    child: const Text(
                      'Set to no data',
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

  resetData() {
    value = 0;
    setAsNoContent();
  }

  invalidate() {
    invalidateBaseBloc();
  }

  dispose() {
    disposeBaseBloc();
  }
}

class Example2 extends StatefulWidget {
  const Example2({Key? key}) : super(key: key);

  @override
  State<Example2> createState() => _Example2State();
}

class _Example2State extends State<Example2> {
  final counterBloc = CounterBloc();
  final newCounterBloc = CounterBloc2();

  @override
  void dispose() {
    super.dispose();
    counterBloc.dispose();
    newCounterBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomStreamBuilder.twoSubject(
                streams: [
                  counterBloc.behaviorSubject,
                  newCounterBloc.behaviorSubject
                ],
                dataBuilder2: (context, data, secondData) {
                  var counterBlocData = data.model as int?;
                  var counterBlocState = data.itemState;
                  var counterBlocDataError = data.error as String?;
                  var newCounterBlocData = secondData.model as double?;
                  var newCounterBlocState = secondData.itemState;
                  var newCounterBlocError = secondData.error as String?;

                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (counterBlocState == ItemState.loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (counterBlocState == ItemState.hasError)
                            Text(
                              'counterBlocData error: $counterBlocDataError',
                              style: const TextStyle(fontSize: 34),
                            )
                          else if (counterBlocState == ItemState.noContent)
                            const SizedBox()
                          else
                            Text(
                              'counterBlocData: $counterBlocData',
                              style: const TextStyle(fontSize: 34),
                            ),
                          const SizedBox(
                            height: 34,
                          ),
                          if (newCounterBlocState == ItemState.loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (newCounterBlocState == ItemState.hasError)
                            Text(
                              'newCounterBlocError error: $newCounterBlocError',
                              style: const TextStyle(fontSize: 34),
                            )
                          else if (newCounterBlocState == ItemState.noContent)
                            const SizedBox()
                          else
                            Text(
                              'newCounterBlocData: $newCounterBlocData',
                              style: const TextStyle(fontSize: 34),
                            ),
                        ],
                      ));
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
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      counterBloc.fetchCurrent(false);
                    },
                    child: const Text(
                      'Add Value to stream 1',
                      style: TextStyle(),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      counterBloc.resetData();
                    },
                    child: const Text(
                      'Set to no data stream 1',
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
                      'Add Error to stream 1',
                      style: TextStyle(),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.fetchCurrent(false);
                    },
                    child: const Text(
                      'Add Value to stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.resetData();
                    },
                    child: const Text(
                      'Set to no data stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.fetchCurrent(true);
                    },
                    child: const Text(
                      'Add Error to stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
            const SizedBox(
              height: 34,
            )
          ],
        ),
      ),
    );
  }
}

class CounterBloc2 with BaseBloc<double, String> {
  double value = 0;

  CounterBloc2() {
    fetchCurrent(false);
  }

  fetchCurrent(bool addError) async {
    setAsLoading();

    if (!addError) {
      await Future.delayed(const Duration(seconds: 2));
      value += 0.5;
      addToModel(value);
    } else {
      value = 0;
      addToError('Could not fetch data');
    }
  }

  resetData() {
    value = 0;
    setAsNoContent();
  }

  invalidate() {
    invalidateBaseBloc();
  }

  dispose() {
    disposeBaseBloc();
  }
}

class ExampleMulti extends StatefulWidget {
  const ExampleMulti({Key? key}) : super(key: key);

  @override
  State<ExampleMulti> createState() => _ExampleMultiState();
}

class _ExampleMultiState extends State<ExampleMulti> {
  final counterBloc = CounterBloc();
  final newCounterBloc = CounterBloc2();

  @override
  void dispose() {
    super.dispose();
    counterBloc.dispose();
    newCounterBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomStreamBuilder.multiSubject(
                streams: [
                  counterBloc.behaviorSubject,
                  newCounterBloc.behaviorSubject
                ],
                itemBuilderMulti: (context, data) {
                  var counterBlocData = data.first.model as int?;
                  var counterBlocState = data.first.itemState;
                  var counterBlocDataError = data.first.error as String?;
                  var newCounterBlocData = data.elementAt(1).model as double?;
                  var newCounterBlocState = data.elementAt(1).itemState;
                  var newCounterBlocError = data.elementAt(1).error as String?;

                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (counterBlocState == ItemState.loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (counterBlocState == ItemState.hasError)
                            Text(
                              'counterBlocData error: $counterBlocDataError',
                              style: const TextStyle(fontSize: 34),
                            )
                          else if (counterBlocState == ItemState.noContent)
                            const SizedBox()
                          else
                            Text(
                              'counterBlocData: $counterBlocData',
                              style: const TextStyle(fontSize: 34),
                            ),
                          const SizedBox(
                            height: 34,
                          ),
                          if (newCounterBlocState == ItemState.loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (newCounterBlocState == ItemState.hasError)
                            Text(
                              'newCounterBlocError error: $newCounterBlocError',
                              style: const TextStyle(fontSize: 34),
                            )
                          else if (newCounterBlocState == ItemState.noContent)
                            const SizedBox()
                          else
                            Text(
                              'newCounterBlocData: $newCounterBlocData',
                              style: const TextStyle(fontSize: 34),
                            ),
                        ],
                      ));
                },
              ),
            ),
            const SizedBox(
              height: 34,
            ),
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      counterBloc.fetchCurrent(false);
                    },
                    child: const Text(
                      'Add Value to stream 1',
                      style: TextStyle(),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      counterBloc.resetData();
                    },
                    child: const Text(
                      'Set to no data stream 1',
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
                      'Add Error to stream 1',
                      style: TextStyle(),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.fetchCurrent(false);
                    },
                    child: const Text(
                      'Add Value to stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.resetData();
                    },
                    child: const Text(
                      'Set to no data stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc.fetchCurrent(true);
                    },
                    child: const Text(
                      'Add Error to stream 2',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
            const SizedBox(
              height: 34,
            )
          ],
        ),
      ),
    );
  }
}
