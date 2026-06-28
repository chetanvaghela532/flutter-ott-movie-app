import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cast_entity.dart';
import '../repositories/movie_repository.dart';

class GetTvShowCast {
  final MovieRepository repository;

  GetTvShowCast(this.repository);

  Future<Either<Failure, List<CastEntity>>> call(int tvShowId) async {
    return await repository.getTvShowCast(tvShowId);
  }
}

