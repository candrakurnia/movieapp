part of 'tv_detail_bloc.dart';

sealed class TvDetailEvent extends Equatable {
  const TvDetailEvent();

  @override
  List<Object?> get props => [];
}

class fetchTvDetailEvent extends TvDetailEvent {
  final int id;

  const fetchTvDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddToWatchlistEventTv extends TvDetailEvent {
  final TvDetail tv;

  const AddToWatchlistEventTv(this.tv);

  @override
  List<Object?> get props => [tv];
}

class RemoveFromWatchlistEvent extends TvDetailEvent {
  final TvDetail tv;

  const RemoveFromWatchlistEvent(this.tv);

  @override
  List<Object?> get props => [tv];
}
