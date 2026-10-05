import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tv.dart';
import 'package:equatable/equatable.dart';

part 'top_rated_tv_event.dart';
part 'top_rated_tv_state.dart';

class TopRatedTvBloc extends Bloc<TopRatedTvEvent, TopRatedTvState> {
  final GetTopRatedTv _getTopRatedTv;
  TopRatedTvBloc(this._getTopRatedTv) : super(TopRatedTvInitial()) {
    on<fetchTopRatedTv>((event, emit) async {
      emit(TopratedTvLoading());

      final result = await _getTopRatedTv.execute();

      result.fold((failure) {
        emit(TopRatedTvError(failure.message));
      }, (tvData) {
        emit(TopRatedTvHasData(tvData));
      });
    });
  }
}
