import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/usecases/get_watchlist_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetWatchlistMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetWatchlistMovies(mockMovieRepository);
  });

  test('should get list of tv from the repository', () async {
    // arrange
    when(mockMovieRepository.getWatchlistTv())
        .thenAnswer((_) async => Right(testTvList));
    // act
    final result = await usecase.executed();
    // assert
    expect(result, Right(testTvList));
  });
}
