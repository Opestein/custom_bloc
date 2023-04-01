/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:rxdart/rxdart.dart';

class BaseBloc<T, E> {
  ///Stream declaration
  final BehaviorSubject<BaseModel<T, E>> _behaviorSubject =
      BehaviorSubject<BaseModel<T, E>>();

  ///getter for the stream
  BehaviorSubject<BaseModel<T, E>> get behaviorSubject => _behaviorSubject;

  ///Base object of the stream
  BaseModel<T, E> baseModel = BaseModel<T, E>(itemState: ItemState.noContent);

  ///Enables the state of bloc to be set to no content state and added to stream
  setAsNoContent() {
    baseModel.setItemState = ItemState.noContent;
    _addToStream();
  }

  ///Enables the state of bloc to be set as loading state and added to stream
  setAsLoading() {
    baseModel.setItemState = ItemState.loading;
    _addToStream();
  }

  ///Enables the object to be added to stream
  addToModel(T _t) {
    baseModel.setModel = _t;
    _addToStream();
  }

  ///Enables the state of bloc to be set as error state and added to stream
  addToError(E _e) {
    baseModel.setError = _e;
    _addToStream();
  }

  ///Update the stream
  _addToStream() => _behaviorSubject.add(baseModel);

  ///Reset the stream
  invalidateBaseBloc() {
    baseModel = BaseModel<T, E>();
    _addToStream();
  }

  ///Checks if stream is opened and close the stream
  disposeBaseBloc() {
    if (!_behaviorSubject.isClosed) {
      _behaviorSubject.close();
    }
  }
}
