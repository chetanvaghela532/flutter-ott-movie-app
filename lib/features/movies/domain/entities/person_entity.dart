import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? knownForDepartment;
  final double? popularity;

  const PersonEntity({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthday,
    this.placeOfBirth,
    this.knownForDepartment,
    this.popularity,
  });

  String get profileUrl {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        profilePath,
        biography,
        birthday,
        placeOfBirth,
        knownForDepartment,
        popularity,
      ];
}

class PersonMovieCreditEntity extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final String? character;
  final String? job;
  final String mediaType; // 'movie' or 'tv'

  const PersonMovieCreditEntity({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.character,
    this.job,
    required this.mediaType,
  });

  String get posterUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        posterPath,
        releaseDate,
        character,
        job,
        mediaType,
      ];
}

