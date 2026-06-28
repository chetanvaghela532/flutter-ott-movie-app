import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_image_entity.dart';
import '../repositories/movie_repository.dart';

class GetTvShowImages {
  final MovieRepository repository;

  GetTvShowImages(this.repository);

  Future<Either<Failure, Map<String, List<MovieImageEntity>>>> call(int tvShowId) async {
    return await repository.getTvShowImages(tvShowId);
  }
}

