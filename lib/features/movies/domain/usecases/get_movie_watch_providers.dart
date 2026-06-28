import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/watch_provider_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieWatchProviders {
  final MovieRepository repository;

  GetMovieWatchProviders(this.repository);

  Future<Either<Failure, List<WatchProviderEntity>>> call(int movieId, {String region = 'US'}) async {
    return await repository.getMovieWatchProviders(movieId, region: region);
  }
}

