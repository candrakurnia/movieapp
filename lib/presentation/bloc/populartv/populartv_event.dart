part of 'populartv_bloc.dart';

sealed class PopulartvEvent extends Equatable {
  const PopulartvEvent();

  @override
  List<Object> get props => [];
}

class FetchPopularTvEvent extends PopulartvEvent {
  
}
