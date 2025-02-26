part of 'tv_detail_bloc.dart';

sealed class TvDetailState extends Equatable {
  const TvDetailState();

  @override
  List<Object> get props => [];
}

class TvDetailInitial extends TvDetailState {}

class TvDetailLoading extends TvDetailState {}

class TvDetailHasData extends TvDetailState {
  final TvDetail result;
  final List<Tv> recommendations;
  final bool isAddedToWatchlist;

  TvDetailHasData({
    required this.result,
    required this.recommendations,
    required this.isAddedToWatchlist,
  });

  @override
  List<Object> get props => [result, recommendations, isAddedToWatchlist];
}

class TvDetailError extends TvDetailState {
  final String message;

  TvDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class WatchlistMessageState extends TvDetailState {
  final String message;

  const WatchlistMessageState(this.message);

  @override
  List<Object> get props => [message];
}

class WatchlistStatusLoaded extends TvDetailState {
  final bool isAddedToWatchlist;

  const WatchlistStatusLoaded(this.isAddedToWatchlist);

  @override
  List<Object> get props => [isAddedToWatchlist];
}
