import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetTvShowDetails {
  final MovieRepository repository;

  GetTvShowDetails(this.repository);

  Future<Either<Failure, MovieEntity>> call(int tvShowId) async {
    return await repository.getTvShowDetails(tvShowId);
  }
}

