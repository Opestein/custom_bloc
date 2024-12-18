import 'package:custom_bloc/custom_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBlocInfiniteLoadingFactoryBloc<T, E> extends BaseBloc {
  int pageNumber = 1;
  int perPage = 20;
  double pixels = 0.0;

  BaseBlocInfiniteLoadingFactoryBloc() {
    _controller.listen((notification) => _fetchNextPage(notification));
    _loaderSubject.add(false);
  }

  final BehaviorSubject<bool> _loaderSubject = BehaviorSubject<bool>();

  BehaviorSubject<bool> get loaderSubject => _loaderSubject;

  final ReplaySubject<ScrollNotification> _controller = ReplaySubject();

  Sink<ScrollNotification> get sink => _controller.sink;

  reload() {}

  initIfEmptyOrError() {}

  initFetch() async {
    _loaderSubject.add(false);
    pageNumber = 1;
    pixels = 0;
  }

  _fetchNextPage(ScrollNotification notification) {
    if (pageNumber != 1) {
      if (notification.metrics.pixels == notification.metrics.maxScrollExtent &&
          pixels != notification.metrics.pixels) {
        pixels = notification.metrics.pixels;

        fetchNextPage(onSuccessfulFetch: () {
          incrementPageCount();
          startLoaderSubject();
        }, onFailedFetch: () {
          stopLoaderSubject();
        });
      }
    }
  }

  fetchNextPage({Function()? onSuccessfulFetch, Function()? onFailedFetch});

  invalidate() {
    pixels = 0;
    invalidateBaseBloc();
  }

  dispose() {
    _controller.close();
    _loaderSubject.close();
    disposeBaseBloc();
  }

  incrementPageCount() => pageNumber = pageNumber + 1;

  incrementPageCountAndStartLoaderSubject() {
    if (!_loaderSubject.isClosed) {
      _loaderSubject.add(true);
    }
  }

  startLoaderSubject() {
    if (!_loaderSubject.isClosed) {
      _loaderSubject.add(true);
    }
  }

  stopLoaderSubject() {
    if (!_loaderSubject.isClosed) {
      _loaderSubject.add(false);
    }
  }
}
