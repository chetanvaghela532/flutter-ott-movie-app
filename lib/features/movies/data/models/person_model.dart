import '../../domain/entities/person_entity.dart';

class PersonModel extends PersonEntity {
  const PersonModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.biography,
    super.birthday,
    super.placeOfBirth,
    super.knownForDepartment,
    super.popularity,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      profilePath: json['profile_path'] as String?,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_path': profilePath,
      'biography': biography,
      'birthday': birthday,
      'place_of_birth': placeOfBirth,
      'known_for_department': knownForDepartment,
      'popularity': popularity,
    };
  }
}

class PersonMovieCreditModel extends PersonMovieCreditEntity {
  const PersonMovieCreditModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.releaseDate,
    super.character,
    super.job,
    required super.mediaType,
  });

  factory PersonMovieCreditModel.fromJson(Map<String, dynamic> json) {
    return PersonMovieCreditModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String?,
      character: json['character'] as String?,
      job: json['job'] as String?,
      mediaType: json['media_type'] as String? ?? 
                 (json['title'] != null ? 'movie' : 'tv'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'character': character,
      'job': job,
      'media_type': mediaType,
    };
  }
}

