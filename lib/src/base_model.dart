/*
*  custom_bloc
*
*  Created by [Folarin Opeyemi].
*  Copyright © 2022. All rights reserved.
    */

import 'package:custom_bloc/src/enum.dart';

class BaseModel<T, E> {
  T? model;
  E? error;
  ItemState itemState;

  BaseModel({this.itemState = ItemState.no_content, this.model, this.error});

  set setModel(T model) {
    this.model = model;
    itemState = ItemState.hasData;
  }

  set setError(E error) {
    this.error = error;
    itemState = ItemState.hasError;
  }

  set setItemState(ItemState state) {
    this.model = null;
    this.error = null;
    itemState = state;
  }

  bool get hasData => itemState == ItemState.hasData && model != null;

  bool get hasError => itemState == ItemState.hasError;

  bool get isLoading => itemState == ItemState.loading;

  bool get noContent => itemState == ItemState.no_content;
}
