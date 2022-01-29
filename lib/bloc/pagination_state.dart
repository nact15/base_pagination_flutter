part of 'pagination_bloc.dart';

enum PaginationStatus { initial, loading, empty, success, error }

@immutable
class PaginationState<T> extends Equatable {
  final PaginationStatus status;

  /// флаг для тех стейтов которые должны быть
  /// услышены в BlocBuilder
  /// если false, то стейт будет услышан только в BlocListener
  final bool build;
  final List<T> items;
  final bool paginationLoading;

  const PaginationState({
    required this.status,
    this.items = const [],
    this.build = true,
    this.paginationLoading = false,
  });

  PaginationState copyWith({
    PaginationStatus? status,
    bool? build,
    bool? paginationLoading,
  }) {
    return PaginationState(
      status: status ?? this.status,
      build: build ?? this.build,
      paginationLoading: paginationLoading ?? false,
    );
  }

  @override
  List<Object?> get props => [status, build, paginationLoading];
}
