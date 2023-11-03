import 'package:freezed_annotation/freezed_annotation.dart';

part '../ticket.freezed.dart';
part '../ticket.g.dart';

enum TicketType {
  @JsonValue('student')
  student,
  @JsonValue('volunteer')
  feature,
}

@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required int id,
    required String name,
    required TicketType type,
    required DateTime created,
    @Default("") String notes,
    DateTime? entered,
    @JsonKey(name: 'is_present') @Default(false) bool isPresent,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}

@freezed
class TicketCreate with _$TicketCreate {
  const factory TicketCreate({
    required int id,
    required String name,
    required TicketType type,
    String? notes,
    DateTime? entered,
    @JsonKey(name: 'is_present') bool? isPresent,
  }) = _TicketCreate;

  factory TicketCreate.fromJson(Map<String, dynamic> json) =>
      _$TicketCreateFromJson(json);
}

@freezed
class TicketUpdate with _$TicketUpdate {
  const factory TicketUpdate({
    required int id,
    String? name,
    TicketType? type,
    String? notes,
    DateTime? entered,
    @JsonKey(name: 'is_present') bool? isPresent,
  }) = _TicketUpdate;

  factory TicketUpdate.fromJson(Map<String, dynamic> json) =>
      _$TicketUpdateFromJson(json);
}