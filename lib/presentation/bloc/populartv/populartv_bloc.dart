import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_popular_tv.dart';
import 'package:equatable/equatable.dart';

part 'populartv_event.dart';
part 'populartv_state.dart';

class PopulartvBloc extends Bloc<PopulartvEvent, PopulartvState> {
  final GetPopularTv _getPopularTv;
  PopulartvBloc(
    this._getPopularTv,
  ) : super(PopulartvEmpty()) {
    on<FetchPopularTvEvent>((event, emit) async {
      emit(PopularTvLoading());

      final result = await _getPopularTv.execute();
      result.fold(
        (failure) {
          emit(PopularTvError(failure.message));
        },
        (tvData) {
          emit(PopularTvHasData(tvData));
        },
      );
    });
  }
}
