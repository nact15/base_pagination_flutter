import 'package:base_pagination/bloc/pagination_bloc.dart';
import 'package:example/domain/user_entity.dart';
import 'package:example/gateway/user_gateway.dart';

class UserBloc extends PaginationBloc<UserEntity> {
  final UserGateway userGateway = UserGateway();

  int _countOfPages = 0;

  @override
  int get countOfPages => _countOfPages;

  @override
  Future<List<UserEntity>> getItems(int page) async {
    final pagination = await userGateway.getUserResponse(page: page);
    _countOfPages = pagination.total ~/ 10;
    return pagination.data;
  }
}