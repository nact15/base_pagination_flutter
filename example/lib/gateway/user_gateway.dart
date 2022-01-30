import 'package:dio/dio.dart';
import 'package:example/domain/user_entity.dart';

class UserGateway {
  final Dio dio = Dio();

  Future<PaginationEntity> getUserResponse({required int page}) async {
    final response = await dio.get(
      'https://dummyapi.io/data/v1/user',
      queryParameters: {
        'page': page,
        'limit': 10,
      },
      options: Options(headers: {'app-id': '61f553388f70dad0c949f4e8'}),
    );
    final Map<String, dynamic> json = response.data;
    return PaginationEntity.fromJson(json);
  }
}
