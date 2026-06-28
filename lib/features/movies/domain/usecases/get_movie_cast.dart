import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cast_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieCast {
  final MovieRepository repository;

  GetMovieCast(this.repository);

  Future<Either<Failure, List<CastEntity>>> call(int movieId) async {
    return await repository.getMovieCast(movieId);
  }
}

