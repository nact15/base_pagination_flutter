import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pagination_event.dart';

part 'pagination_state.dart';

abstract class PaginationResponseData<T> {
  /// метод для запроса получения айтемов
}

abstract class PaginationPages {
  int get countOfPages;
}

abstract class PaginationBloc<T> extends Bloc<PaginationEvent, PaginationState<T>>
    implements PaginationPages, PaginationResponseData<T> {
  PaginationBloc() : super(const PaginationState<T>(status: PaginationStatus.initial)) {
    on<PaginationFetch>(_onPaginationFetch, transformer: droppable());
    on<PaginationRefresh>((event, emit) {
      _isLastPage = false;
      _page = 1;
      _items.clear();
      _onPaginationFetch(event, emit);
    }, transformer: droppable());
  }

  Future<List<T>> getItems(_page);

  bool _isLastPage = false;
  late List<T> _items;

  int _page = 1;

  Future<FutureOr<void>> _onPaginationFetch(_, Emitter<PaginationState<T>> emit) async {
    try {
      if (_page == 1) {
        _items = [];
        emit(PaginationState<T>(status: PaginationStatus.loading));
      }
      if (!_isLastPage) {
        state.copyWith(paginationLoading: true);
        _items.addAll(await getItems(_page));
        _page++;
        _isLastPage = _page > countOfPages;
        if (_items.isNotEmpty) {
          emit(
            PaginationState<T>(
              status: PaginationStatus.success,
              items: _items,
            ),
          );
        } else {
          emit(PaginationState<T>(status: PaginationStatus.empty));
        }
      }
    } catch (e) {
      if (_items.isNotEmpty) {
        emit(
          PaginationState<T>(
            status: PaginationStatus.error,
            build: false,
          ),
        );
      } else {
        emit(PaginationState<T>(status: PaginationStatus.error));
      }
    }
  }
}
