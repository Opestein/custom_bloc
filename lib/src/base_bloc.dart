/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2022. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:rxdart/rxdart.dart';

class BaseBloc<T, E> {
  final BehaviorSubject<BaseModel<T, E>> _behaviorSubject =
      BehaviorSubject<BaseModel<T, E>>();

  BehaviorSubject<BaseModel<T, E>> get behaviorSubject => _behaviorSubject;
  BaseModel<T, E> baseModel = BaseModel<T, E>(itemState: ItemState.loading);

  setAsLoading() {
    baseModel.setItemState = ItemState.loading;
    _addToStream();
  }

  addToModel(T _t) {
    baseModel.setModel = _t;
    _addToStream();
  }

  addToError(E _e) {
    baseModel.setError = _e;
    _addToStream();
  }

  _addToStream() => _behaviorSubject.add(baseModel);

  invalidateBaseBloc() {
    baseModel = BaseModel<T, E>();
    _addToStream();
  }

  disposeBaseBloc() {
    _behaviorSubject.close();
  }
}
