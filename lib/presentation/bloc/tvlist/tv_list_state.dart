part of 'tv_list_bloc.dart';

sealed class TvListState extends Equatable {
  const TvListState();

  @override
  List<Object> get props => [];
}

class TvListInitial extends TvListState {}

class TvListLoading extends TvListState {}

class TvListHasData extends TvListState {
  final List<Tv> onAiringTv;
  final List<Tv> popularTv;
  final List<Tv> topRatedTv;

  TvListHasData({
    required this.onAiringTv,
    required this.popularTv,
    required this.topRatedTv,
  });

  @override
  List<Object> get props => [onAiringTv, popularTv, topRatedTv];
}

class TvListError extends TvListState {
  final String message;

  TvListError(this.message);

  @override
  List<Object> get props => [message];
}
