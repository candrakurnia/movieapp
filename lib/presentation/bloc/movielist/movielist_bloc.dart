import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:equatable/equatable.dart';

part 'movielist_event.dart';
part 'movielist_state.dart';

class MovielistBloc extends Bloc<MovielistEvent, MovielistState> {
  final GetNowPlayingMovies getNowPlayingMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final GetPopularMovies getPopularMovies;

  MovielistBloc({
    required this.getNowPlayingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
  }) : super(MovieListEmpty()) {
    on<fetchNowPlayingMovies>((event, emit) async {
      emit(MovieListloading());

      final nowPlayingResult = await getNowPlayingMovies.execute();
      final popularResult = await getPopularMovies.execute();
      final topRatedResult = await getTopRatedMovies.execute();

      nowPlayingResult.fold(
        (failure) {
          emit(MovieListError(failure.message));
          return;
        },
        (nowPlayingMovies) async {
          popularResult.fold(
            (failure) {
              emit(MovieListError(failure.message));
              return;
            },
            (popularMovies) async {
              topRatedResult.fold(
                (failure) {
                  emit(MovieListError(failure.message));
                },
                (topRatedMovies) {
                  emit(MovieListLoaded(
                    nowPlayingMovies: nowPlayingMovies,
                    popularMovies: popularMovies,
                    topRatedMovies: topRatedMovies,
                  ));
                },
              );
            },
          );
        },
      );

      // final result = await getNowPlayingMovies.execute();

      // result.fold(
      //   (failure) {
      //     emit(MovieListError(failure.message));
      //   },
      //   (nowPlayingMovies) {
      //     emit(MovieListLoaded(nowPlayingMovies: nowPlayingMovies));
      //   },
      // );
    });

    // on<fetchTopRatedMovies>((event, emit) async {
    //   emit(MovieListloading());
    //   final result = await getTopRatedMovies.execute();

    //   result.fold(
    //     (failure) {
    //       emit(MovieListError(failure.message));
    //     },
    //     (topRatedMovies) {
    //       emit(MovieListLoaded(topRatedMovies: topRatedMovies));
    //     },
    //   );
    // });

    // on<fetchPopularMovies>((event, emit) async {
    //   emit(MovieListloading());

    //   final result = await getPopularMovies.execute();

    //   result.fold(
    //     (failure) {
    //       emit(MovieListError(failure.message));
    //     },
    //     (popularMovies) {
    //       emit(MovieListLoaded(popularMovies: popularMovies));
    //     },
    //   );
    // });
  }
}
