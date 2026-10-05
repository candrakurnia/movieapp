import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tv.dart';
import 'package:ditonton/domain/usecases/get_popular_tv.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tv.dart';
import 'package:equatable/equatable.dart';

part 'tv_list_event.dart';
part 'tv_list_state.dart';

class TvListBloc extends Bloc<TvListEvent, TvListState> {
  final GetNowPlayingTv _getNowPlayingTv;
  final GetPopularTv _getPopularTv;
  final GetTopRatedTv _getTopRatedTv;

  TvListBloc(
    this._getNowPlayingTv,
    this._getPopularTv,
    this._getTopRatedTv,
  ) : super(TvListInitial()) {
    on<fetchTvListData>((event, emit) async {
      emit(TvListLoading());

      final nowPlayingResult = await _getNowPlayingTv.execute();
      final popularResult = await _getPopularTv.execute();
      final topRatedResult = await _getTopRatedTv.execute();

      nowPlayingResult.fold(
        (failure) {
          emit(TvListError(failure.message));
          return;
        },
        (nowPlayingTv) {
          popularResult.fold(
            (failure) {
              emit(TvListError(failure.message));
              return;
            },
            (popularTv) {
              topRatedResult.fold(
                (failure) {
                  emit(TvListError(failure.message));
                },
                (topRatedTv) {
                  emit(
                    TvListHasData(
                      onAiringTv: nowPlayingTv,
                      popularTv: popularTv,
                      topRatedTv: topRatedTv,
                    ),
                  );
                },
              );
            },
          );
        },
      );
    });
  }
}
