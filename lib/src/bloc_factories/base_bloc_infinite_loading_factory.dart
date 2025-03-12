import 'package:custom_bloc/custom_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

  class BaseBlocInfiniteLoadingFactoryBloc<T, E> extends BaseBloc<T, E> {
  int pageNumber = 1;
  int perPage = 20;
  double lastPixelPosition = 0.0;

  BaseBlocInfiniteLoadingFactoryBloc(
      {Function(ScrollNotification scrollNotification)? fetchNextPage}) {
    _scrollControllerCC.listen((notification) => (fetchNextPage != null)
        ? fetchNextPage(notification)
        : _fetchNextPage(notification));
    _loadingMoreStream.add(false);
  }

  final BehaviorSubject<bool> _loadingMoreStream = BehaviorSubject<bool>();

  BehaviorSubject<bool> get loadingMoreStream => _loadingMoreStream;

  ValueStream<bool> get isLoadingMore => _loadingMoreStream.stream;

  final ReplaySubject<ScrollNotification> _scrollControllerCC = ReplaySubject();

  Sink<ScrollNotification> get sinkScrollNotification =>
      _scrollControllerCC.sink;

  resetInfiniteDependencies() {
    _loadingMoreStream.add(false);
    pageNumber = 1;
    lastPixelPosition = 0;
  }

  _fetchNextPage(ScrollNotification notification) {
    if (pageNumber != 1) {
      if (notification.metrics.pixels == notification.metrics.maxScrollExtent &&
          lastPixelPosition != notification.metrics.pixels) {
        lastPixelPosition = notification.metrics.pixels;

        fetchNextPage(startLoadingMore: () {
          incrementPageCount();
          startLoadingMore();
        }, stopLoadingMore: () {
          stopLoadingMore();
        });
      }
    }
  }

  /// Override if you want to conform;
  fetchNextPage({Function()? startLoadingMore, Function()? stopLoadingMore}) {

  }

  invalidate() {
    pageNumber = 1;
    lastPixelPosition = 0;
    invalidateBaseBloc();
  }

  dispose() {
    _loadingMoreStream.close();
    disposeBaseBloc();
  }

  // Below are helper functions
  incrementPageCount() => pageNumber = pageNumber + 1;

  incrementPageCountAndStartLoadingMore() {
    if (!_loadingMoreStream.isClosed) {
      _loadingMoreStream.add(true);
    }
  }

  startLoadingMore() {
    if (!_loadingMoreStream.isClosed) {
      _loadingMoreStream.add(true);
    }
  }

  stopLoadingMore() {
    if (!_loadingMoreStream.isClosed) {
      _loadingMoreStream.add(false);
    }
  }
}
