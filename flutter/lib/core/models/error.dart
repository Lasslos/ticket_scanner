import 'package:freezed_annotation/freezed_annotation.dart';

part '../error.freezed.dart';
part '../error.g.dart';

@freezed
class HTTPValidationError with _$HTTPValidationError {
  const factory HTTPValidationError({
    required List<HTTPValidationErrorDetail> detail,
  }) = _HTTPValidationError;

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) =>
      _$HTTPValidationErrorFromJson(json);
}

@freezed
class HTTPValidationErrorDetail with _$HTTPValidationErrorDetail {
  const factory HTTPValidationErrorDetail({
    required List<dynamic> loc,
    required String msg,
    required String type,
  }) = _HTTPValidationErrorDetail;

  factory HTTPValidationErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$HTTPValidationErrorDetailFromJson(json);
}

@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required List<dynamic> loc,
    required String msg,
    required String type,
  }) = _ValidationError;

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
}
