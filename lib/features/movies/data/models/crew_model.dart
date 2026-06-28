import '../../domain/entities/crew_entity.dart';

class CrewModel extends CrewEntity {
  const CrewModel({
    required super.id,
    required super.name,
    super.job,
    super.department,
    super.profilePath,
  });

  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: json['id'] as int,
      name: json['name'] as String,
      job: json['job'] as String?,
      department: json['department'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'department': department,
      'profile_path': profilePath,
    };
  }
}

