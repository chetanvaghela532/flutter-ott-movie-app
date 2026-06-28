import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetSimilarTvShows {
  final MovieRepository repository;

  GetSimilarTvShows(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call(int tvShowId, {int page = 1}) async {
    return await repository.getSimilarTvShows(tvShowId, page: page);
  }
}

