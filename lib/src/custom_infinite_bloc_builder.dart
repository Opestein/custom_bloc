/*
*  CustomInfiniteBlocBuilder
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:flutter/material.dart';

typedef AsyncDataWidgetInfiniteBlocBuilder<L, T, E> = Widget Function(
    BuildContext context,
    ItemState itemState,
    L? isLoadingMore,
    T? data,
    E? error);

///Widget class for the library.
///Basically wraps around and abstract a StreamBuilder widget
class CustomInfiniteBlocBuilder<L, T, E> extends StatelessWidget {
  ///initial data
  BaseModel<T, E>? initialData;

  ///initial data for both stream
  BaseModel<List<BaseModel<dynamic, dynamic>>, E>? initialData2;

  ///initial data for all stream
  List<BaseModel<dynamic, dynamic>>? initialDataMulti;

  ///the loading bloc
  Stream<L?>? loadingMoreStream;

  ///the actual bloc
  Stream<BaseModel<T, E>>? stream;

  ///the list of blocs
  List<Stream<BaseModel<dynamic, dynamic>>>? streams;

  ///called when [addToModel] is called on bloc
  AsyncDataWidgetInfiniteBlocBuilder<L, T, E>? builder;

  CustomInfiniteBlocBuilder(
      {Key? key,
      required this.loadingMoreStream,
      required this.stream,
      required this.builder,
      this.initialData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _singleStream();
  }

  Widget _singleStream() {
    return StreamBuilder<L?>(
        stream: loadingMoreStream,
        builder: (context, loadingSnapshot) {
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
                      loadingSnapshot.hasData ? loadingSnapshot.data : null,
                      snapshot.data?.model,
                      snapshot.data?.error);
                }

                return const SizedBox();
              });
        });
  }
}
