part of 'on_airing_tv_bloc.dart';

sealed class OnairingtvState extends Equatable {
  const OnairingtvState();

  @override
  List<Object> get props => [];
}

class OnAiringTvEmpty extends OnairingtvState {}

class OnAiringTvLoading extends OnairingtvState {}

class OnAiringTvLoaded extends OnairingtvState {
  final List<Tv> result;

  OnAiringTvLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class OnAiringTvError extends OnairingtvState {
  final String message;

  OnAiringTvError(this.message);

   @override
  List<Object> get props => [message];
}
