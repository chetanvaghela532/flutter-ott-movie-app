import 'package:equatable/equatable.dart';

class MovieImageEntity extends Equatable {
  final String? filePath;
  final double? aspectRatio;
  final int? height;
  final int? width;
  final double? voteAverage;
  final int? voteCount;

  const MovieImageEntity({
    this.filePath,
    this.aspectRatio,
    this.height,
    this.width,
    this.voteAverage,
    this.voteCount,
  });

  String get imageUrl {
    if (filePath == null || filePath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/original$filePath';
  }

  String get posterUrl {
    if (filePath == null || filePath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$filePath';
  }

  String get backdropUrl {
    if (filePath == null || filePath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w1280$filePath';
  }

  @override
  List<Object?> get props => [filePath, aspectRatio, height, width, voteAverage, voteCount];
}

