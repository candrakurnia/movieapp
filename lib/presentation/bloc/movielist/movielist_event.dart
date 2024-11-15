part of 'movielist_bloc.dart';

sealed class MovielistEvent extends Equatable {
  const MovielistEvent();

  @override
  List<Object> get props => [];
}

class fetchNowPlayingMovies extends MovielistEvent {}
