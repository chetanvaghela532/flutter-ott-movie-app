import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/person_entity.dart';
import '../repositories/movie_repository.dart';

class SearchPerson {
  final MovieRepository repository;

  SearchPerson(this.repository);

  Future<Either<Failure, List<PersonEntity>>> call(String query, {int page = 1}) async {
    return await repository.searchPerson(query, page: page);
  }
}

