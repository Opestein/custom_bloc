/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef AsyncDataWidgetBuilder<T> = Widget Function(
    BuildContext context, T data);
typedef AsyncDataWidgetBuilder2<T, T2> = Widget Function(
    BuildContext context, T snapshot, T2 snapshot2);
typedef AsyncDataWidgetBuilderMulti = Widget Function(
    BuildContext context, List<BaseModel> snapshots);
typedef AsyncErrorWidgetBuilder<E> = Widget Function(
    BuildContext context, E error);
typedef AsyncLoadingWidgetBuilder = Widget Function(BuildContext context);
typedef AsyncNoContentWidgetBuilder = Widget Function(BuildContext context);

///Widget class for the library.
///Basically wraps around and abstract a StreamBuilder widget
class CustomStreamBuilder<T, E, T2, E2> extends StatelessWidget {
  ///initial data
  BaseModel<T, E>? initialData;

  ///initial data for both stream
  BaseModel<List<BaseModel<dynamic, dynamic>>, E>? initialData2;

  ///initial data for all stream
  List<BaseModel<dynamic, dynamic>>? initialDataMulti;

  ///the actual bloc
  Stream<BaseModel<T, E>>? stream;

  ///the list of blocs
  List<Stream<BaseModel<dynamic, dynamic>>>? streams;

  ///called when [addToModel] is called on bloc
  AsyncDataWidgetBuilder<T>? dataBuilder;

  ///called when [addToModel] is called on on either bloc
  AsyncDataWidgetBuilder2<BaseModel<T?, E?>, BaseModel<T2?, E2?>>? dataBuilder2;

  ///called when all stream has been loaded at least once
  AsyncDataWidgetBuilderMulti? itemBuilderMulti;

  ///called when [addToError] is called on bloc
  AsyncErrorWidgetBuilder<E>? errorBuilder;

  ///called when [setAsLoading] is called on bloc
  AsyncLoadingWidgetBuilder? loadingBuilder;

  ///called when [setAsNoContent] is called on bloc
  AsyncNoContentWidgetBuilder? noContentBuilder;

  int _streamCount = 1;

  CustomStreamBuilder(
      {Key? key,
      required this.stream,
      required this.dataBuilder,
      this.errorBuilder,
      this.loadingBuilder,
      this.noContentBuilder,
      this.initialData})
      : super(key: key);

  CustomStreamBuilder.twoSubject(
      {super.key,
      required this.streams,
      required this.dataBuilder2,
      this.errorBuilder,
      this.loadingBuilder,
      this.noContentBuilder,
      this.initialData2})
      : assert((streams?.length ?? 0) == 2) {
    _streamCount = 2;
  }

  CustomStreamBuilder.multiSubject(
      {super.key,
      required this.streams,
      required this.itemBuilderMulti,
      this.initialDataMulti})
      : assert((streams?.length ?? 0) > 0) {
    _streamCount = 1000;
  }

  @override
  Widget build(BuildContext context) {
    if (_streamCount == 2) {
      return _twoStream();
    } else if (_streamCount == 1000) {
      return _multiStream();
    }

    return _singleStream();
  }

  Widget _singleStream() {
    return StreamBuilder<BaseModel<T, E>>(
        stream: stream,
        initialData: initialData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.hasData && dataBuilder != null) {
              return dataBuilder!(context, snapshot.data!.model!);
            } else if (snapshot.data!.hasError) {
              if (errorBuilder != null) {
                return errorBuilder!(context, snapshot.data!.error!);
              }
              return const SizedBox();
            } else if (snapshot.data!.isLoading) {
              if (loadingBuilder != null) {
                return loadingBuilder!(context);
              }
              return const SizedBox();
            } else {
              if (noContentBuilder != null) {
                return noContentBuilder!(context);
              }
              return const SizedBox();
            }
          }

          return const SizedBox();
        });
  }

  ///This StreamBuilder require each streams to be loaded at least once.
  ///You can call set to no content for each bloc to make sure bloc each blocs are initialised
  Widget _twoStream() {
    return StreamBuilder<BaseModel<List<BaseModel<dynamic, dynamic>>, E>>(
        stream: CombineLatestStream.combine2(
            streams!.first, streams!.elementAt(1), (a, b) {
          return BaseModel(model: [
            BaseModel(
                model: a.hasData ? (a.model) : null,
                itemState: a.itemState,
                error: a.hasError ? (a.error) : null),
            BaseModel(
                model: b.hasData ? (b.model) : null,
                itemState: b.itemState,
                error: b.hasError ? (b.error) : null)
          ], itemState: ItemState.hasData);
        }),
        initialData: initialData2,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.hasData && dataBuilder2 != null) {
              return dataBuilder2!(
                  context,
                  BaseModel<T?, E?>(
                      model: snapshot.data?.model?.first.model as T?,
                      error: snapshot.data?.model?.first.error as E?,
                      itemState: snapshot.data?.model?.first.itemState ??
                          ItemState.noContent),
                  BaseModel<T2?, E2?>(
                      model: snapshot.data?.model?.elementAt(1).model as T2?,
                      error: snapshot.data?.model?.elementAt(1).error as E2?,
                      itemState: snapshot.data?.model?.elementAt(1).itemState ??
                          ItemState.noContent));
            } else if (snapshot.data!.hasError) {
              if (errorBuilder != null) {
                return errorBuilder!(context, snapshot.data!.error!);
              }
              return const SizedBox();
            } else if (snapshot.data!.isLoading) {
              if (loadingBuilder != null) {
                return loadingBuilder!(context);
              }
              return const SizedBox();
            } else {
              if (noContentBuilder != null) {
                return noContentBuilder!(context);
              }
              return const SizedBox();
            }
          }

          return const SizedBox();
        });
  }

  ///This StreamBuilder require each streams to be loaded at least once.
  ///You can call set to no content for each bloc to make sure bloc each blocs are initialised
  Widget _multiStream() {
    return StreamBuilder<List<BaseModel<dynamic, dynamic>>>(
        stream: Rx.combineLatestList(streams!),
        initialData: initialDataMulti,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              itemBuilderMulti != null) {
            return itemBuilderMulti!(context, snapshot.data!);
          }

          return const SizedBox();
        });
  }
}
