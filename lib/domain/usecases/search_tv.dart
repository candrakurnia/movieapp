import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/repositories/movie_repository.dart';

class SearchTv {
  final MovieRepository repository;

  SearchTv(this.repository);

  Future<Either<Failure, List<Tv>>> execute(String query) {
    return repository.searchTv(query);
  }
}
