import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String username,
    required String password,
  }) = _User;

factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserCreate with _$UserCreate {
  const factory UserCreate({
    required String username,
    required String password,
    required String key,
  }) = _UserCreate;

  factory UserCreate.fromJson(Map<String, dynamic> json) =>
      _$UserCreateFromJson(json);
}

@freezed
class Token with _$Token {
  const factory Token({
    @JsonKey(name: "access_token") required String accessToken,
    @JsonKey(name: "token_type") required String tokenType,
  }) = _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
