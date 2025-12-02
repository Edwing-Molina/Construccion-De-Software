import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';

part 'specialty.g.dart';

@JsonSerializable(explicitToJson: true)
class Specialty {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  // Relación muchos-a-muchos con Doctor
  @JsonKey(name: 'doctors')
  final List<Doctor>? doctors;

  Specialty({required this.id, required this.name, this.doctors});

  factory Specialty.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyFromJson(json);
  Map<String, dynamic> toJson() => _$SpecialtyToJson(this);
}
