/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/base_model.dart';
import 'package:custom_bloc/src/enum.dart';
import 'package:rxdart/rxdart.dart';

enum BlocType {
  ///This is a BehaviorSubject. This will always broadcast the latest data to any new subscriber.
  ///It will always broadcast the last added item.i.e. latest item
  alwaysBroadcastLatestToAllListeners,

  ///This is a PublishSubject. Data must be added before listening to this or else any new
  ///subscriber will not get any data if they subscribe after
  ///any helper function is called.
  broadcastOnlyIfIsCurrentlyListening,

  ///This is a ReplaySubject. This will always replay for a new listener from the time the first item
  /// was added down to the most recent.
  alwaysReplayAllItemsToNewListener
}

class BaseBloc<T, E> {
  BlocType _blocType = BlocType.alwaysBroadcastLatestToAllListeners;

  BlocType get blocType => _blocType;

  set(BlocType type) {
    _blocType = type;
  }

  ///Stream declaration
  var _behaviorSubject;

  BaseBloc() {
    _behaviorSubject = _blocType == BlocType.alwaysReplayAllItemsToNewListener
        ? ReplaySubject<BaseModel<T, E>>()
        : _blocType == BlocType.broadcastOnlyIfIsCurrentlyListening
            ? PublishSubject<BaseModel<T, E>>()
            : BehaviorSubject<BaseModel<T, E>>.seeded(BaseModel<T, E>());
  }

  ///getter for the stream
  BehaviorSubject<BaseModel<T, E>> get behaviorSubject => _behaviorSubject;

  ///Getter for stream
  ValueStream<BaseModel<T, E>> get stream => behaviorSubject.stream;

  ///returns true if [bloc] is equal to [_baseModel.hasData] and [model] is not null
  bool get blocHasData =>
      behaviorSubject.hasValue &&
      behaviorSubject.value.hasData &&
      behaviorSubject.value.model != null;

  ///returns true if [bloc] is equal to [_baseModel.hasError] and [error] is not null
  bool get blocHasError =>
      behaviorSubject.hasValue &&
      behaviorSubject.value.hasError &&
      behaviorSubject.value.error != null;

  ///returns true if [bloc] is equal to [_baseModel.isLoading]
  bool get blocIsLoading =>
      behaviorSubject.hasValue && behaviorSubject.value.isLoading;

  ///returns true if [bloc] is equal to [_baseModel.isLoading]
  bool get blocHasNoContent =>
      behaviorSubject.hasValue && behaviorSubject.value.noContent;

  ///getter for nullable data
  T? get dataNullable => blocHasData ? _behaviorSubject.value.model : null;

  ///getter for data
  ///Note: This will throw an exception, make sure to check if there is data by
  ///calling [blocHasData] before using this variable
  T get data {
    if (!blocHasData) {
      throw Exception(
          "Bloc does not appear to have any data. Make sure you have previously addDataToModel");
    }
    return _behaviorSubject.value.model!;
  }

  ///getter for nullable error
  E? get errorNullable => blocHasError ? _behaviorSubject.value.error : null;

  ///getter for error.
  ///Note: This will throw an exception, make sure to check if there is error by
  ///calling [blocHasError] before using this variable
  E get error {
    if (!blocHasError) {
      throw Exception(
          "Bloc does not appear to have any error. Make sure you have previously addToError");
    }
    return _behaviorSubject.value.error!;
  }

  ///Getter for Base object
  BaseModel<T, E> get baseModel => _baseModel;

  ///Base object of the stream
  BaseModel<T, E> _baseModel = BaseModel<T, E>(itemState: ItemState.noContent);

  ///Enables the state of bloc to be set to no content state and added to stream
  setAsNoContent() {
    _baseModel.setItemState = ItemState.noContent;
    _addToStream();
  }

  ///Enables the state of bloc to be set as loading state and added to stream
  setAsLoading() {
    _baseModel.setItemState = ItemState.loading;
    _addToStream();
  }

  ///Enables the object to be added to stream
  addToModel(T _t) {
    _baseModel.setModel = _t;
    _addToStream();
  }

  ///Enables the state of bloc to be set as error state and added to stream
  addToError(E _e) {
    _baseModel.setError = _e;
    _addToStream();
  }

  ///Update the stream
  _addToStream() {
    if (!_behaviorSubject.isClosed()) {
      _behaviorSubject.add(_baseModel);
    }
  }

  ///merge stream
  ///call this when you want to merge data that have similar result together
  Stream<BaseModel<T, E>> mergeStreams(
      Iterable<Stream<BaseModel<T, E>>> streams) {
    return _behaviorSubject.mergeWith(streams);
  }

  ///Reset the stream
  invalidateBaseBloc() {
    _baseModel = BaseModel<T, E>();
    _addToStream();
  }

  ///Checks if stream is opened and close the stream
  disposeBaseBloc() {
    if (!_behaviorSubject.isClosed) {
      _behaviorSubject.close();
    }
  }
}
