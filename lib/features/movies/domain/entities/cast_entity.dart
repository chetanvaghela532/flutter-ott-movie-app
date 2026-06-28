import 'package:equatable/equatable.dart';

class CastEntity extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  const CastEntity({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  String get profileUrl {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }

  @override
  List<Object?> get props => [id, name, character, profilePath];
}

