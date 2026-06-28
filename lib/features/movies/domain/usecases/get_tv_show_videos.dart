import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_entity.dart';
import '../repositories/movie_repository.dart';

class GetTvShowVideos {
  final MovieRepository repository;

  GetTvShowVideos(this.repository);

  Future<Either<Failure, List<VideoEntity>>> call(int tvShowId) async {
    return await repository.getTvShowVideos(tvShowId);
  }
}

