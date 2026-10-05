import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:ditonton/presentation/bloc/movielist/movielist_bloc.dart';
import 'package:ditonton/common/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'movie_list_bloc_test.mocks.dart';

@GenerateMocks([GetNowPlayingMovies, GetPopularMovies, GetTopRatedMovies])
void main() {
  late MovielistBloc movielistBloc;
  late MockGetNowPlayingMovies mockGetNowPlayingMovies;
  late MockGetPopularMovies mockGetPopularMovies;
  late MockGetTopRatedMovies mockGetTopRatedMovies;

  final tMovie = Movie(
    adult: false,
    backdropPath: 'backdropPath',
    genreIds: [1, 2, 3],
    id: 1,
    originalTitle: 'originalTitle',
    overview: 'overview',
    popularity: 1,
    posterPath: 'posterPath',
    releaseDate: 'releaseDate',
    title: 'title',
    video: false,
    voteAverage: 1,
    voteCount: 1,
  );

  final tMovieList = <Movie>[tMovie];

  setUp(() {
    mockGetNowPlayingMovies = MockGetNowPlayingMovies();
    mockGetPopularMovies = MockGetPopularMovies();
    mockGetTopRatedMovies = MockGetTopRatedMovies();
    movielistBloc = MovielistBloc(
      getNowPlayingMovies: mockGetNowPlayingMovies,
      getPopularMovies: mockGetPopularMovies,
      getTopRatedMovies: mockGetTopRatedMovies,
    );
  });

  group('MovielistBloc', () {
    blocTest<MovielistBloc, MovielistState>(
      'should emit [MovieListloading, MovieListLoaded] when all use cases return data successfully',
      build: () {
        when(mockGetNowPlayingMovies.execute()).thenAnswer((_) async => Right(tMovieList));
        when(mockGetPopularMovies.execute()).thenAnswer((_) async => Right(tMovieList));
        when(mockGetTopRatedMovies.execute()).thenAnswer((_) async => Right(tMovieList));
        return movielistBloc;
      },
      act: (bloc) => bloc.add(fetchNowPlayingMovies()),
      expect: () => [
        MovieListloading(),
        MovieListLoaded(
          nowPlayingMovies: tMovieList,
          popularMovies: tMovieList,
          topRatedMovies: tMovieList,
        ),
      ],
      verify: (_) {
        verify(mockGetNowPlayingMovies.execute());
        verify(mockGetPopularMovies.execute());
        verify(mockGetTopRatedMovies.execute());
      },
    );

    blocTest<MovielistBloc, MovielistState>(
      'should emit [MovieListloading, MovieListError] when one use case fails',
      build: () {
        when(mockGetNowPlayingMovies.execute()).thenAnswer((_) async => Right(tMovieList));
        when(mockGetPopularMovies.execute()).thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(mockGetTopRatedMovies.execute()).thenAnswer((_) async => Right(tMovieList));
        return movielistBloc;
      },
      act: (bloc) => bloc.add(fetchNowPlayingMovies()),
      expect: () => [
        MovieListloading(),
        MovieListError('Server Failure'),
      ],
      verify: (_) {
        verify(mockGetNowPlayingMovies.execute());
        verify(mockGetPopularMovies.execute());
        verify(mockGetTopRatedMovies.execute());
      },
    );

    blocTest<MovielistBloc, MovielistState>(
      'should emit [MovieListloading, MovieListError] when multiple use cases fail',
      build: () {
        when(mockGetNowPlayingMovies.execute()).thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(mockGetPopularMovies.execute()).thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(mockGetTopRatedMovies.execute()).thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return movielistBloc;
      },
      act: (bloc) => bloc.add(fetchNowPlayingMovies()),
      expect: () => [
        MovieListloading(),
        MovieListError('Server Failure'),
      ],
      verify: (_) {
        verify(mockGetNowPlayingMovies.execute());
        verify(mockGetPopularMovies.execute());
        verify(mockGetTopRatedMovies.execute());
      },
    );
  });
}
