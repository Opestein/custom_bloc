/*
*  CustomInfiniteScrollingStreamBuilder
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:flutter/material.dart';

typedef AsyncDataWidgetInfiniteScrollingBuilder<bool> = Widget Function(
    BuildContext context, bool data);

///Widget class for the library.
///Basically wraps around and abstract a StreamBuilder widget
class CustomInfiniteScrollingStreamBuilder extends StatelessWidget {
  ///initial data
  bool? initialData;

  ///the loader bloc
  Stream<bool>? loaderStream;

  ///called when [addToModel] is called on bloc
  AsyncDataWidgetInfiniteScrollingBuilder<bool>? builder;

  CustomInfiniteScrollingStreamBuilder(
      {Key? key, this.loaderStream, required this.builder, this.initialData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: loaderStream,
        builder: (context, loadingSnapshot) {
          bool loadingData =
              loadingSnapshot.hasData ? (loadingSnapshot.data ?? false) : false;

          if (builder != null) {
            return builder!(context, loadingData);
          }

          return const SizedBox();
        });
  }
}
