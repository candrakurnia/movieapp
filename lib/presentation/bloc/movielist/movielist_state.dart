part of 'movielist_bloc.dart';

sealed class MovielistState extends Equatable {
  const MovielistState();
  
  @override
  List<Object> get props => [];
}

class MovieListEmpty extends MovielistState {}

class MovieListloading extends MovielistState{}

class MovieListError extends MovielistState {
  final String message;

  MovieListError(this.message);

  @override
  List<Object> get props => [message];
}

class MovieListLoaded extends MovielistState {
  final List<Movie> nowPlayingMovies;
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;

  MovieListLoaded({
    this.nowPlayingMovies = const [],
    this.popularMovies = const [],
    this.topRatedMovies = const [],
  });

  @override
  List<Object> get props => [nowPlayingMovies, popularMovies, topRatedMovies];
}
