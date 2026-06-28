import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieVideos {
  final MovieRepository repository;

  GetMovieVideos(this.repository);

  Future<Either<Failure, List<VideoEntity>>> call(int movieId) async {
    return await repository.getMovieVideos(movieId);
  }
}

