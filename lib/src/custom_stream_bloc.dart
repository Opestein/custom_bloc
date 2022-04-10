/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2022. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:flutter/material.dart';

typedef AsyncDataWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);
typedef AsyncErrorWidgetBuilder<T, E> = Widget Function(
    BuildContext context, E error);
typedef AsyncLoadingWidgetBuilder = Widget Function(BuildContext context);

class CustomStreamBuilder<T, E> extends StatelessWidget {
  BaseModel<T, E>? data = BaseModel<T, E>();
  final Stream<BaseModel<T, E>>? stream;
  final AsyncDataWidgetBuilder<T> dataBuilder;
  final AsyncErrorWidgetBuilder<T, E>? errorBuilder;
  final AsyncLoadingWidgetBuilder? loadingBuilder;

  CustomStreamBuilder(
      {Key? key,
      required this.stream,
      required this.dataBuilder,
      this.errorBuilder,
      this.loadingBuilder,
      this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BaseModel<T, E>>(
        stream: stream,
        initialData: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.hasData) {
              return dataBuilder(context, snapshot.data!.model!);
            } else if (snapshot.data!.hasError) {
              if (errorBuilder != null) {
                return errorBuilder!(context, snapshot.data!.error!);
              }
              return const SizedBox();
            } else {
              if (loadingBuilder != null) {
                return loadingBuilder!(context);
              }
              return const SizedBox();
            }
          }

          return const SizedBox();
        });
  }
}

typedef OnRetryCallback = Function();

class CustomBlocErrorWidget extends StatelessWidget {
  final OnRetryCallback? onPressed;
  final String buttonText;
  final Color buttonColor;
  final String title;
  final Widget? child;

  const CustomBlocErrorWidget(
      {Key? key,
      this.onPressed,
      this.buttonText = 'Retry',
      this.buttonColor = Colors.red,
      this.title = 'No item found',
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        child ??
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(
                height: 34,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.subtitle2!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 14,
              )
            ]),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Material(
            color: theme.buttonTheme.colorScheme!.primary,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                if (onPressed != null) onPressed!();
              },
              borderRadius: BorderRadius.circular(10),
              splashFactory: InkSplash.splashFactory,
              splashColor: Colors.black45,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 55,
                child: Text(
                  title,
                  style: theme.textTheme.bodyText2!.copyWith(
                      color: theme.buttonTheme.colorScheme?.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
