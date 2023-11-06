import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

enum TicketType {
  @JsonValue('student')
  student(name: "Schüler", icon: Icons.school),
  @JsonValue('volunteer')
  volunteer(name: "Helfer", icon: Icons.volunteer_activism);
  
  const TicketType({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

@freezed
class Ticket with _$Ticket {
  @JsonSerializable(includeIfNull: false)
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
  @JsonSerializable(includeIfNull: false)
  const factory TicketCreate({
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
  @JsonSerializable(includeIfNull: false)
  const factory TicketUpdate({
    String? name,
    TicketType? type,
    String? notes,
    DateTime? entered,
    @JsonKey(name: 'is_present') bool? isPresent,
  }) = _TicketUpdate;

  factory TicketUpdate.fromJson(Map<String, dynamic> json) =>
      _$TicketUpdateFromJson(json);
}
