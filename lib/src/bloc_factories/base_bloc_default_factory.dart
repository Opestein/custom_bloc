import 'package:custom_bloc/custom_bloc.dart';

abstract class BaseBlocDefaultFactoryBloc<T, E> extends BaseBloc {
  reload() {
    initFetch();
  }

  initFetch() {}

  initIfEmptyOrError() {}
}
