import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tv.dart';
import 'package:equatable/equatable.dart';

part 'on_airing_tv_event.dart';
part 'on_airing_tv_state.dart';

class OnairingtvBloc extends Bloc<OnairingtvEvent, OnairingtvState> {
  final GetNowPlayingTv _getNowPlayingTv;
  OnairingtvBloc(this._getNowPlayingTv) : super(OnAiringTvEmpty()) {
    on<OnairingtvEvent>((event, emit) async {
      emit(OnAiringTvLoading());

      final result = await _getNowPlayingTv.execute();
      result.fold(
        (failure) {
          emit(OnAiringTvError(failure.message));
        },
        (onAiring) {
          emit(
            OnAiringTvLoaded(onAiring),
          );
        },
      );
    });
  }
}
