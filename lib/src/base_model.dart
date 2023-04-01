/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2023. All rights reserved.
    */

import 'package:custom_bloc/src/enum.dart';

///Base class for the library
class BaseModel<T, E> {
  T? model;
  E? error;
  ItemState itemState;

  BaseModel({this.itemState = ItemState.noContent, this.model, this.error});

  ///set the base class to it's generic [model] value
  set setModel(T model) {
    this.model = model;
    this.error = null;
    itemState = ItemState.hasData;
  }

  ///set the base class to it's generic [error] value
  set setError(E error) {
    this.model = null;
    this.error = error;
    itemState = ItemState.hasError;
  }

  ///Set both [model] and [error] to null and takes in any [ItemState]
  set setItemState(ItemState state) {
    this.model = null;
    this.error = null;
    itemState = state;
  }

  ///returns true if [itemState] is equal to [ItemState.hasData] and [model] is not null
  bool get hasData => itemState == ItemState.hasData && model != null;

  ///returns true if [itemState] is equal to [ItemState.hasError]
  bool get hasError => itemState == ItemState.hasError;

  ///returns true if [itemState] is equal to [ItemState.loading]
  bool get isLoading => itemState == ItemState.loading;

  ///returns true if [itemState] is equal to [ItemState.noContent]
  bool get noContent => itemState == ItemState.noContent;
}
