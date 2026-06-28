import 'package:equatable/equatable.dart';

class CrewEntity extends Equatable {
  final int id;
  final String name;
  final String? job;
  final String? department;
  final String? profilePath;

  const CrewEntity({
    required this.id,
    required this.name,
    this.job,
    this.department,
    this.profilePath,
  });

  String get profileUrl {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }

  @override
  List<Object?> get props => [id, name, job, department, profilePath];
}

