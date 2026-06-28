import '../../domain/entities/movie_image_entity.dart';

class MovieImageModel extends MovieImageEntity {
  const MovieImageModel({
    super.filePath,
    super.aspectRatio,
    super.height,
    super.width,
    super.voteAverage,
    super.voteCount,
  });

  factory MovieImageModel.fromJson(Map<String, dynamic> json) {
    return MovieImageModel(
      filePath: json['file_path'] as String?,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
      height: json['height'] as int?,
      width: json['width'] as int?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'aspect_ratio': aspectRatio,
      'height': height,
      'width': width,
      'vote_average': voteAverage,
      'vote_count': voteCount,
    };
  }
}

