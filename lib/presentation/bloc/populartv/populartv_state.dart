part of 'populartv_bloc.dart';

sealed class PopulartvState extends Equatable {
  const PopulartvState();

  @override
  List<Object> get props => [];
}

class PopulartvEmpty extends PopulartvState {}

class PopularTvLoading extends PopulartvState {}

class PopularTvHasData extends PopulartvState {
  final List<Tv> result;

  PopularTvHasData(this.result);

  @override
  List<Object> get props => [result];
}

class PopularTvError extends PopulartvState {
  final String message;

  PopularTvError(this.message);

  @override
  List<Object> get props => [message];
}
