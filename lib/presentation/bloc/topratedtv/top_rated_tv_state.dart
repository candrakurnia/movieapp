part of 'top_rated_tv_bloc.dart';

sealed class TopRatedTvState extends Equatable {
  const TopRatedTvState();
  
  @override
  List<Object> get props => [];
}

class TopRatedTvInitial extends TopRatedTvState {}

class TopratedTvLoading extends TopRatedTvState {}

class TopRatedTvHasData extends TopRatedTvState {
  final List<Tv> result;

  TopRatedTvHasData(this.result);

  @override
  List<Object> get props => [result];

}

class TopRatedTvError extends TopRatedTvState {
  final String message;

  TopRatedTvError(this.message);

  @override
  List<Object> get props => [message];

}


