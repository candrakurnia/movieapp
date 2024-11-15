import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:equatable/equatable.dart';

part 'top_rated_movies_event.dart';
part 'top_rated_movies_state.dart';

class TopRatedMoviesBloc extends Bloc<TopRatedMoviesEvent, TopRatedMoviesState> {
  final GetTopRatedMovies _getTopRatedMovies;
  TopRatedMoviesBloc(this._getTopRatedMovies) : super(TopRatedMoviesEmpty()) {
    on<fetchTopRatedMovies>((event, emit) async {

       final result = await _getTopRatedMovies.execute();
      result.fold(
        (failure) {
          emit(TopRatedMoviesError(failure.message));
        },
        (moviesData) {
          emit(TopRatedMoviesHasData(moviesData));
        },
      );
    });
  }
}
