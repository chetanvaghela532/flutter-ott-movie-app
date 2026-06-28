import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetTopRatedTvShows {
  final MovieRepository repository;

  GetTopRatedTvShows(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call({int page = 1}) async {
    return await repository.getTopRatedTvShows(page: page);
  }
}

