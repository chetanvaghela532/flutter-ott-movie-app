import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/watch_provider_entity.dart';
import '../repositories/movie_repository.dart';

class GetTvShowWatchProviders {
  final MovieRepository repository;

  GetTvShowWatchProviders(this.repository);

  Future<Either<Failure, List<WatchProviderEntity>>> call(int tvShowId, {String region = 'US'}) async {
    return await repository.getTvShowWatchProviders(tvShowId, region: region);
  }
}

