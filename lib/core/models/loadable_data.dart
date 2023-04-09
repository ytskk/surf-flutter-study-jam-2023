import 'package:flutter/material.dart';

class LoadableData<T> {
  const LoadableData({
    this.data,
    this.status = LoadingStatus.initial,
    this.error,
  });

  final T? data;
  final LoadingStatus status;
  final Object? error;

  loading() {
    return copyWith(status: LoadingStatus.loading);
  }

  loaded(T data) {
    return copyWith(
      status: LoadingStatus.loaded,
      data: data,
    );
  }

  hasError(Object error) {
    return copyWith(
      status: LoadingStatus.error,
      error: error,
    );
  }

  when({
    Widget Function()? initial,
    required Widget Function() loading,
    required Widget Function(T data) loaded,
    required Widget Function(Object error) error,
  }) {
    switch (status) {
      case LoadingStatus.initial:
        return initial?.call() ?? loading();
      case LoadingStatus.loading:
        return loading();
      case LoadingStatus.loaded:
        return loaded(data!);
      case LoadingStatus.error:
        return error(error);
    }
  }

  LoadableData<T> copyWith({
    T? data,
    LoadingStatus? status,
    Object? error,
  }) {
    return LoadableData<T>(
      data: data ?? this.data,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

enum LoadingStatus {
  initial,
  loading,
  loaded,
  error,
}
