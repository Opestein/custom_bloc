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
              child: CustomStreamBuilder(
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

class CounterBloc extends BaseBloc<int, String> {
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
                dataBuilder2: (context, BaseModel<int?, String?> data,
                    BaseModel<double?, String?> secondData) {
                  var counterBlocData = data.model;
                  var counterBlocState = data.itemState;
                  var counterBlocDataError = data.error;
                  var newCounterBlocData = secondData.model;
                  var newCounterBlocState = secondData.itemState;
                  var newCounterBlocError = secondData.error;

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
                  error.toString(),
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

class CounterBloc2 extends BaseBlocInfiniteLoadingFactoryBloc<double, String> {
  double value = 0;

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

  @override
  fetchNextPage(
      {Function()? startLoadingMore, Function()? stopLoadingMore}) async {
    await Future.delayed(const Duration(seconds: 2));
    value += 0.5;
    addToModel(value);
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
  final newCounterBloc3 = CounterBloc3();

  @override
  void dispose() {
    super.dispose();
    counterBloc.dispose();
    newCounterBloc.dispose();
    newCounterBloc3.dispose();
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
                  newCounterBloc.behaviorSubject,
                  newCounterBloc3.behaviorSubject
                ],
                itemBuilderMulti: (context, data) {
                  var counterBlocData = data.first.model as int?;
                  var counterBlocState = data.first.itemState;
                  var counterBlocDataError = data.first.error as String?;

                  var newCounterBlocData = data.elementAt(1).model as double?;
                  var newCounterBlocState = data.elementAt(1).itemState;
                  var newCounterBlocError = data.elementAt(1).error as String?;

                  var newCounterBlocData3 = data.elementAt(2).model as double?;
                  var newCounterBlocState3 = data.elementAt(2).itemState;
                  var newCounterBlocError3 = data.elementAt(2).error as String?;

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
                          if (newCounterBlocState3 == ItemState.loading)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (newCounterBlocState3 == ItemState.hasError)
                            Text(
                              'newCounterBlocError error: $newCounterBlocError3',
                              style: const TextStyle(fontSize: 34),
                            )
                          else if (newCounterBlocState3 == ItemState.noContent)
                            const SizedBox()
                          else
                            Text(
                              'newCounterBlocData: $newCounterBlocData3',
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
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc3.fetchCurrent(false);
                    },
                    child: const Text(
                      'Add Value to stream 3',
                      style: TextStyle(color: Colors.purple),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc3.resetData();
                    },
                    child: const Text(
                      'Set to no data stream 3',
                      style: TextStyle(color: Colors.purple),
                    )),
                const SizedBox(
                  width: 34,
                ),
                TextButton(
                    onPressed: () {
                      newCounterBloc3.fetchCurrent(true);
                    },
                    child: const Text(
                      'Add Error to stream 3',
                      style: TextStyle(color: Colors.purple),
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

class CounterBloc3 extends BaseBloc<double, String> {
  double value = 0;

  CounterBloc3() {
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

class ExampleCustomBlocBuilder extends StatefulWidget {
  const ExampleCustomBlocBuilder({Key? key}) : super(key: key);

  @override
  State<ExampleCustomBlocBuilder> createState() =>
      _ExampleCustomBlocBuilderState();
}

class _ExampleCustomBlocBuilderState extends State<ExampleCustomBlocBuilder> {
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
              child: CustomBlocBuilder(
                  stream: counterBloc.behaviorSubject,
                  builder: (context, itemState, data, error) {
                    if (itemState == ItemState.hasData) {
                      return ListView.separated(
                        itemCount: 1,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 24),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                    } else if (itemState == ItemState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (itemState == ItemState.loading) {
                      return Text(
                        error ?? '',
                        style: const TextStyle(),
                      );
                    }
                    return const SizedBox();
                  }),
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

class CounterInfiniteScrollingBloc
    extends BaseBlocInfiniteLoadingFactoryBloc<double, String> {
  int get page => pageNumber;

  int get itemsPerPage => perPage;

  double value = 0;

  initFetch() async {
    setAsLoading();

    await Future.delayed(const Duration(seconds: 2));
    value += 0.5;
    addToModel(value);

    incrementPageCountAndStartLoadingMore();
  }

  @override
  fetchNextPage(
      {Function()? startLoadingMore, Function()? stopLoadingMore}) async {
    bool isSuccessful = await Future.delayed(const Duration(seconds: 2));

    if (isSuccessful) {
      value += 0.5;
      addToModel(value);
      if (startLoadingMore != null) {
        startLoadingMore();
      }
    } else {
      if (stopLoadingMore != null) {
        stopLoadingMore();
      }
    }
  }

  resetData() {
    value = 0;
    setAsNoContent();
  }

  @override
  invalidate() {
   super.invalidate();
  }

  @override
  dispose() {
    super.dispose();
  }
}

class ExampleInfiniteScrolling extends StatefulWidget {
  const ExampleInfiniteScrolling({Key? key}) : super(key: key);

  @override
  State<ExampleInfiniteScrolling> createState() =>
      _ExampleInfiniteScrollingState();
}

class _ExampleInfiniteScrollingState extends State<ExampleInfiniteScrolling> {
  final counterBloc = CounterInfiniteScrollingBloc();

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
              child: CustomInfiniteScrollingStreamBuilder(
                loaderStream: counterBloc.loadingMoreStream,
                builder: (context, loadingData) => CustomStreamBuilder(
                  stream: counterBloc.behaviorSubject,
                  dataBuilder: (context, data) {
                    return NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollNotification) {
                          counterBloc.sinkScrollNotification.add(notification);
                        }
                        return true;
                      },
                      child: ListView.separated(
                        itemCount: 1,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 24),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                      ),
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
            ),
            const SizedBox(
              height: 34,
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      counterBloc.fetchNextPage();
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
                      counterBloc.fetchNextPage();
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

class ExampleInfiniteScrollingWithCustomBlocBuilder extends StatefulWidget {
  const ExampleInfiniteScrollingWithCustomBlocBuilder({Key? key})
      : super(key: key);

  @override
  State<ExampleInfiniteScrollingWithCustomBlocBuilder> createState() =>
      _ExampleInfiniteScrollingWithCustomBlocBuilderState();
}

class _ExampleInfiniteScrollingWithCustomBlocBuilderState
    extends State<ExampleInfiniteScrollingWithCustomBlocBuilder> {
  final counterBloc = CounterInfiniteScrollingBloc();

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
              child: CustomInfiniteScrollingStreamBuilder(
                loaderStream: counterBloc.loadingMoreStream,
                builder: (context, loadingData) => CustomInfiniteBlocBuilder(
                  loadingMoreStream: counterBloc.loadingMoreStream,
                  stream: counterBloc.behaviorSubject,
                  builder: (context, state, isLoadingMore, data, error) {
                    if (state == ItemState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state == ItemState.hasError) {
                      return Text(
                        '$error',
                        style: const TextStyle(),
                      );
                    }
                    return NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollNotification) {
                          counterBloc.sinkScrollNotification.add(notification);
                        }
                        return true;
                      },
                      child: ListView.separated(
                        itemCount: 1,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 24),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                      ),
                    );
                  },
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
                      counterBloc.fetchNextPage();
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
                      counterBloc.fetchNextPage();
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
