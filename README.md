<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A simple custom stream builder library based on BLOC pattern. Uses stream underneath.

## Features

This allows easy adding of data from network and disposing of bloc

## How To Use Custom Bloc

```dart
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
              loadingBuilder: (context) =>
              const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error) =>
                  Text(
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

```

