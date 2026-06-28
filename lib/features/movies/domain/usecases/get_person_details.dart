import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/person_entity.dart';
import '../repositories/movie_repository.dart';

class GetPersonDetails {
  final MovieRepository repository;

  GetPersonDetails(this.repository);

  Future<Either<Failure, PersonEntity>> call(int personId) async {
    return await repository.getPersonDetails(personId);
  }
}

