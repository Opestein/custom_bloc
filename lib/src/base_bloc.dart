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
  late Subject<BaseModel<T, E>> _behaviorSubject;

  /// for checking if publish stream has value
  BaseModel<T, E>? _latestPublishedValue;

  BaseBloc() {
    _behaviorSubject = _blocType == BlocType.alwaysReplayAllItemsToNewListener
        ? ReplaySubject<BaseModel<T, E>>()
        : _blocType == BlocType.broadcastOnlyIfIsCurrentlyListening
            ? PublishSubject<BaseModel<T, E>>()
            : BehaviorSubject<BaseModel<T, E>>.seeded(BaseModel<T, E>());

    if (_behaviorSubject is PublishSubject) {
      _behaviorSubject.listen((value) {
        _latestPublishedValue = value;
      });
    }
  }

  ///getter for the stream
  Subject<BaseModel<T, E>> get behaviorSubject => _behaviorSubject;

  ///Getter for stream
  Stream<BaseModel<T, E>> get stream => behaviorSubject.stream;

  ///returns true if [bloc] is equal to [_baseModel.hasData] and [model] is not null
  bool get blocHasData {
    if (_behaviorSubject is BehaviorSubject<BaseModel<T, E>>) {
      final behaviorSubject =
          _behaviorSubject as BehaviorSubject<BaseModel<T, E>>;
      return behaviorSubject.hasValue &&
          behaviorSubject.value.hasData &&
          behaviorSubject.value.model != null;
    } else if (_behaviorSubject is ReplaySubject<BaseModel<T, E>>) {
      final replaySubject = _behaviorSubject as ReplaySubject<BaseModel<T, E>>;

      // final currentValue = replaySubject.valueOrNull;
      // return currentValue != null && currentValue.hasData && currentValue.model != null;

      bool hasEmittedData = false;
      BaseModel<T, E>? latestValue;

      final subscription = replaySubject.stream.listen((value) {
        hasEmittedData = true;
        latestValue = value;
      });

      subscription.cancel();

      return hasEmittedData &&
          latestValue != null &&
          latestValue!.hasData &&
          latestValue!.model != null;
    } else if (_behaviorSubject is PublishSubject<BaseModel<T, E>>) {
      return _latestPublishedValue != null &&
          _latestPublishedValue!.hasData &&
          _latestPublishedValue!.model != null;
    } else {
      return false;
    }
  }

  /// [BlocType.alwaysReplayAllItemsToNewListener] would return true if there has ever
  /// been any error added to the bloc
  ///
  /// [BlocType.alwaysBroadcastLatestToAllListeners] would always return true if only
  /// the last item added to bloc was was error
  ///
  /// [BlocType.broadcastOnlyIfIsCurrentlyListening] would return true to listener only
  /// if the last added item is an error after listener subscribe
  bool get blocHasError {
    if (_behaviorSubject is BehaviorSubject<BaseModel<T, E>>) {
      final behaviorSubject =
          _behaviorSubject as BehaviorSubject<BaseModel<T, E>>;
      return behaviorSubject.hasValue &&
          behaviorSubject.value.hasError &&
          behaviorSubject.value.error != null;
    } else if (_behaviorSubject is ReplaySubject<BaseModel<T, E>>) {
      final replaySubject = _behaviorSubject as ReplaySubject<BaseModel<T, E>>;

      bool hasEmittedData = false;
      BaseModel<T, E>? latestValue;

      final subscription = replaySubject.stream.listen((value) {
        hasEmittedData = true;
        latestValue = value;
      });

      subscription.cancel();

      return hasEmittedData &&
          latestValue != null &&
          latestValue!.hasError &&
          latestValue!.error != null;
    } else if (_behaviorSubject is PublishSubject<BaseModel<T, E>>) {
      return _latestPublishedValue != null &&
          _latestPublishedValue!.hasError &&
          _latestPublishedValue!.error != null;
    } else {
      return false;
    }
  }

  ///returns true if [bloc] is equal to [_baseModel.isLoading]
  bool get blocIsLoading {
    if (_behaviorSubject is BehaviorSubject<BaseModel<T, E>>) {
      final behaviorSubject =
          _behaviorSubject as BehaviorSubject<BaseModel<T, E>>;
      return behaviorSubject.hasValue && behaviorSubject.value.isLoading;
    } else if (_behaviorSubject is ReplaySubject<BaseModel<T, E>>) {
      final replaySubject = _behaviorSubject as ReplaySubject<BaseModel<T, E>>;
      bool hasEmittedData = false;
      BaseModel<T, E>? latestValue;

      final subscription = replaySubject.stream.listen((value) {
        hasEmittedData = true;
        latestValue = value;
      });

      subscription.cancel();

      return hasEmittedData && latestValue != null && latestValue!.isLoading;
    } else if (_behaviorSubject is PublishSubject<BaseModel<T, E>>) {
      return _latestPublishedValue != null && _latestPublishedValue!.isLoading;
    } else {
      return false;
    }
  }

  ///returns true if [bloc] is equal to [_baseModel.noContent]
  bool get blocHasNoContent {
    if (_behaviorSubject is BehaviorSubject<BaseModel<T, E>>) {
      final behaviorSubject =
          _behaviorSubject as BehaviorSubject<BaseModel<T, E>>;
      return behaviorSubject.hasValue && behaviorSubject.value.noContent;
    } else if (_behaviorSubject is ReplaySubject<BaseModel<T, E>>) {
      // For ReplaySubject, access the latest value through a temporary subscription
      final replaySubject = _behaviorSubject as ReplaySubject<BaseModel<T, E>>;
      bool hasEmittedData = false;
      BaseModel<T, E>? latestValue;

      final subscription = replaySubject.stream.listen((value) {
        hasEmittedData = true;
        latestValue = value;
      });

      subscription.cancel();

      return hasEmittedData && latestValue != null && latestValue!.noContent;
    } else if (_behaviorSubject is PublishSubject<BaseModel<T, E>>) {
      // For PublishSubject, use the manually tracked value
      return _latestPublishedValue != null && _latestPublishedValue!.noContent;
    } else {
      return false;
    }
  }

  ///getter for nullable data
  T? get dataNullable => blocHasData ? _getCurrentValue()?.model : null;

  ///getter for data
  ///Note: This will throw an exception, make sure to check if there is data by
  ///calling [blocHasData] before using this variable
  T get data {
    if (!blocHasData) {
      throw Exception(
          "Bloc does not appear to have any data. Make sure you have previously addDataToModel");
    }
    return _getCurrentValue()!.model!;
  }

  ///getter for nullable error
  E? get errorNullable => blocHasError ? _getCurrentValue()?.error : null;

// Helper method to get current value from any Subject type
  BaseModel<T, E>? _getCurrentValue() {
    if (_behaviorSubject is BehaviorSubject<BaseModel<T, E>>) {
      return (_behaviorSubject as BehaviorSubject<BaseModel<T, E>>).value;
    } else if (_behaviorSubject is ReplaySubject<BaseModel<T, E>>) {
      // For ReplaySubject, we need to use a subscription to get the current value
      final replaySubject = _behaviorSubject as ReplaySubject<BaseModel<T, E>>;
      BaseModel<T, E>? latestValue;

      final subscription = replaySubject.stream.listen((value) {
        latestValue = value;
      });

      subscription.cancel();

      return latestValue;
    } else if (_behaviorSubject is PublishSubject<BaseModel<T, E>>) {
      // For PublishSubject, use our manually tracked value
      return _latestPublishedValue;
    }

    return null;
  }

  ///getter for error.
  ///Note: This will throw an exception, make sure to check if there is error by
  ///calling [blocHasError] before using this variable
  E get error {
    if (!blocHasError) {
      throw Exception(
          "Bloc does not appear to have any error. Make sure you have previously addToError");
    }
    return _getCurrentValue()!.error!;
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
    if (_behaviorSubject.isClosed == false) {
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
    if (_behaviorSubject.isClosed == false) {
      _behaviorSubject.close();
    }
  }
}
