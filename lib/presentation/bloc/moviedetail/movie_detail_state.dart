import 'package:equatable/equatable.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;

  const MovieDetailLoaded({
    required this.movie,
    required this.recommendations,
    required this.isAddedToWatchlist,
  });

  @override
  List<Object> get props => [movie, recommendations, isAddedToWatchlist];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class WatchlistMessageState extends MovieDetailState {
  final String message;

  const WatchlistMessageState(this.message);

  @override
  List<Object> get props => [message];
}

class WatchlistStatusLoaded extends MovieDetailState {
  final bool isAddedToWatchlist;

  const WatchlistStatusLoaded(this.isAddedToWatchlist);

  @override
  List<Object> get props => [isAddedToWatchlist];
}
