import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetSimilarMovies {
  final MovieRepository repository;

  GetSimilarMovies(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call(int movieId, {int page = 1}) async {
    return await repository.getSimilarMovies(movieId, page: page);
  }
}

