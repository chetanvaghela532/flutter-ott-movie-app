import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_image_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieImages {
  final MovieRepository repository;

  GetMovieImages(this.repository);

  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> call(int movieId) async {
    return await repository.getMovieImages(movieId);
  }
}

