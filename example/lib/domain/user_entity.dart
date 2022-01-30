class PaginationEntity {
  final int total;
  final int page;
  final int limit;
  final List<UserEntity> data;

  PaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.data,
  });

  factory PaginationEntity.fromJson(Map<String, dynamic> json) {
    return PaginationEntity(
      page: json['page'],
      total: json['total'],
      limit: json['limit'],
      data: (json['data'] as List).map((e) => UserEntity.fromJson(e)).toList(),
    );
  }
}

class UserEntity {
  final String title;
  final String firstName;
  final String lastName;
  final String picture;

  UserEntity({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.picture,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      picture: json['picture'],
    );
  }
}
