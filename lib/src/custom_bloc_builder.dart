/*
*  CustomBlocBuilder
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef AsyncDataWidgetBlocBuilder<T, E> = Widget Function(
    BuildContext context, ItemState itemState, T? data, E? error);
typedef AsyncDataWidgetBlocBuilder2<T, T2> = Widget Function(
    BuildContext context, T snapshot, T2 snapshot2);
typedef AsyncDataWidgetBlocBuilderMulti = Widget Function(
    BuildContext context, List<BaseModel> snapshots);

///Widget class for the library.
///Basically wraps around and abstract a StreamBuilder widget
class CustomBlocBuilder<T, E, T2, E2> extends StatelessWidget {
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
  AsyncDataWidgetBlocBuilder<T, E>? builder;

  ///called when [addToModel] is called on on either bloc
  AsyncDataWidgetBlocBuilder2<BaseModel<T?, E?>, BaseModel<T2?, E2?>>?
      dataBuilder2;

  ///called when all stream has been loaded at least once
  AsyncDataWidgetBlocBuilderMulti? itemBuilderMulti;

  int _streamCount = 1;

  CustomBlocBuilder(
      {Key? key, required this.stream, required this.builder, this.initialData})
      : super(key: key);

  CustomBlocBuilder.twoSubject(
      {super.key,
      required this.streams,
      required this.dataBuilder2,
      this.initialData2})
      : assert((streams?.length ?? 0) == 2) {
    _streamCount = 2;
  }

  CustomBlocBuilder.multiSubject(
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
          if (builder != null) {
            return builder!(
                context,
                snapshot.data?.hasData == true
                    ? ItemState.hasData
                    : snapshot.data?.hasError == true
                        ? ItemState.hasError
                        : snapshot.data?.isLoading == true
                            ? ItemState.loading
                            : ItemState.noContent,
                snapshot.data?.model,
                snapshot.data?.error);
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
          if (dataBuilder2 != null) {
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
          }

          return const SizedBox();
        });
  }

  ///This StreamBuilder require each streams to be loaded at least once.
  ///You can call set to no content for each bloc to make sure bloc each blocs are initialised
  Widget _multiStream() {
    return StreamBuilder<List<BaseModel<dynamic, dynamic>>>(
        stream: streams != null ? Rx.combineLatestList(streams!) : null,
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
