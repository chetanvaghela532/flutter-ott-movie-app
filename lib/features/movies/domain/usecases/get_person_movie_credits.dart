import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/person_entity.dart';
import '../repositories/movie_repository.dart';

class GetPersonMovieCredits {
  final MovieRepository repository;

  GetPersonMovieCredits(this.repository);

  Future<Either<Failure, Map<String, List<PersonMovieCreditEntity>>>> call(int personId) async {
    return await repository.getPersonMovieCredits(personId);
  }
}

