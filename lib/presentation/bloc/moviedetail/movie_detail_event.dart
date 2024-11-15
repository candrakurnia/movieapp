import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:equatable/equatable.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieDetailEvent extends MovieDetailEvent {
  final int id;

  const FetchMovieDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddToWatchlistEvent extends MovieDetailEvent {
  final MovieDetail movie;

  const AddToWatchlistEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class RemoveFromWatchlistEvent extends MovieDetailEvent {
  final MovieDetail movie;

  const RemoveFromWatchlistEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class LoadWatchlistStatusEvent extends MovieDetailEvent {
  final int id;

  const LoadWatchlistStatusEvent(this.id);

  @override
  List<Object?> get props => [id];
}
