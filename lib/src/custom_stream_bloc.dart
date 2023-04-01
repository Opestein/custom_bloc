/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:flutter/material.dart';

typedef AsyncDataWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);
typedef AsyncErrorWidgetBuilder<T, E> = Widget Function(
    BuildContext context, E error);
typedef AsyncLoadingWidgetBuilder = Widget Function(BuildContext context);

///Widget class for the library.
///Basically wraps around and abstract a StreamBuilder widget
class CustomStreamBuilder<T, E> extends StatelessWidget {
  final BaseModel<T, E>? initialData;
  final Stream<BaseModel<T, E>>? stream;
  final AsyncDataWidgetBuilder<T> dataBuilder;
  final AsyncErrorWidgetBuilder<T, E>? errorBuilder;
  final AsyncLoadingWidgetBuilder? loadingBuilder;

  const CustomStreamBuilder(
      {Key? key,
      required this.stream,
      required this.dataBuilder,
      this.errorBuilder,
      this.loadingBuilder,
      this.initialData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BaseModel<T, E>>(
        stream: stream,
        initialData: initialData,
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

///A simple button that can be used to display errors
class CustomBlocErrorWidget extends StatelessWidget {
  final OnRetryCallback? onPressed;
  final String buttonText;
  final Color buttonColor;
  final String title;
  final Widget? child;
  final double buttonHeight;
  final double maxButtonWidth;
  final double buttonBorderRadius;
  final Color buttonPressSplashColor;

  const CustomBlocErrorWidget(
      {Key? key,
      this.onPressed,
      this.buttonText = 'Retry',
      this.buttonColor = Colors.red,
      this.title = 'No item found',
      this.child,
      this.buttonHeight = 55,
      this.maxButtonWidth = 450,
      this.buttonBorderRadius = 10,
      this.buttonPressSplashColor = Colors.black45})
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
                style: theme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 14,
              )
            ]),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxButtonWidth),
          child: Material(
            color: theme.buttonTheme.colorScheme!.primary,
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            child: InkWell(
              onTap: () {
                if (onPressed != null) onPressed!();
              },
              borderRadius: BorderRadius.circular(buttonBorderRadius),
              splashFactory: InkSplash.splashFactory,
              splashColor: buttonPressSplashColor,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: buttonHeight,
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge!
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
