import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pagination_event.dart';

part 'pagination_state.dart';

abstract class PaginationResponseData<T> {
  /// метод для запроса получения айтемов
  /// В нем необходимо сетить countOfPages
  Future<List<T>> getItems(int page);
}

abstract class PaginationPages {
  /// Количесвто страниц из запроса на пагинацию
  int get countOfPages;
}

abstract class PaginationBloc<T> extends Bloc<PaginationEvent, PaginationState<T>>
    implements PaginationPages, PaginationResponseData<T> {
  PaginationBloc() : super(PaginationState<T>(status: PaginationStatus.initial)) {
    on<PaginationFetch>(_onPaginationFetch, transformer: droppable());
    on<PaginationRefresh>((event, emit) {
      _isLastPage = false;
      _page = 1;
      _items.clear();
      _onPaginationFetch(event, emit);
    }, transformer: droppable());
  }

  bool _isLastPage = false;
  late List<T> _items;

  int _page = 1;

  Future<FutureOr<void>> _onPaginationFetch(_, Emitter<PaginationState<T>> emit) async {
    try {
      if (!_isLastPage) {
        if (_page == 1) {
          _items = [];
          emit(state.copyWith(status: PaginationStatus.loading));
        } else {
          emit(state.copyWith(paginationLoading: true));
        }
        _items.addAll(await getItems(_page));
        _page++;
        _isLastPage = _page > countOfPages;
        if (_items.isNotEmpty) {
          emit(
            state.copyWith(
              status: PaginationStatus.success,
              items: _items,
            ),
          );
        } else {
          emit(state.copyWith(status: PaginationStatus.empty));
        }
      }
    } catch (e) {
      if (_items.isNotEmpty) {
        emit(
          state.copyWith(
            status: PaginationStatus.error,
            build: false,
          ),
        );
      } else {
        emit(state.copyWith(status: PaginationStatus.error));
      }
    }
  }
}
