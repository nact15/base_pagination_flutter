part of 'pagination_bloc.dart';

@immutable
abstract class PaginationEvent {}

class PaginationFetch extends PaginationEvent {}
class PaginationRefresh extends PaginationEvent {}