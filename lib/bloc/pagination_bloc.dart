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
  /// Количество страниц из запроса на пагинацию
  // TODO: придумать что-то получше этого
  int get countOfPages;
}

abstract class PaginationBloc<T> extends Bloc<PaginationEvent, PaginationState<T>>
    implements PaginationPages, PaginationResponseData<T> {
  PaginationBloc({int? initialPage})
      : _page = initialPage ?? 1,
        _initialPage = initialPage,
        super(
          PaginationState<T>(status: PaginationStatus.initial),
        ) {
    on<PaginationFetch>(_onPaginationFetch, transformer: droppable());
    on<PaginationRefresh>((event, emit) {
      _isLastPage = false;
      _page = _initialPage ?? 1;
      _items.clear();
      _onPaginationFetch(event, emit);
    }, transformer: droppable());
  }

  late List<T> _items;
  late int _page;
  late final int? _initialPage;
  bool _isLastPage = false;

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
      // TODO: когда будет общий хэндлер для ошибок, то их можно будет здесь адекватно обработать
      // а может и нет
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
