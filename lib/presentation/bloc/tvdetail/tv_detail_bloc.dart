import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:equatable/equatable.dart';

part 'tv_detail_event.dart';
part 'tv_detail_state.dart';

class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetTvDetail getTvDetail;
  final GetMovieRecommendations getTvRecommendations;
  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;
  TvDetailBloc({
    required this.getTvDetail,
    required this.getTvRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(TvDetailInitial()) {
    on<fetchTvDetailEvent>((event, emit) async {
      emit(TvDetailLoading());
      final detailResult = await getTvDetail.execute(event.id);
      final recommendationResult =
          await getTvRecommendations.executed(event.id);

      await detailResult.fold(
        (failure) async {
          emit(TvDetailError(failure.message));
        },
        (tvDetail) async {
          final recommendationState = await recommendationResult.fold<List<Tv>>(
            (failure) => <Tv>[],
            (recommendations) => recommendations,
          );

          final isAddedToWatchlist = await getWatchListStatus.executed(event.id);

          emit(
            TvDetailHasData(
              result: tvDetail,
              recommendations: recommendationState,
              isAddedToWatchlist: isAddedToWatchlist,
            ),
          );
        },
      );
    });

    on<AddToWatchlistEventTv>((event, emit) async {
      final result = await saveWatchlist.executed(event.tv);

      await result.fold(
        (failure) async {
          emit(WatchlistMessageState(failure.message));
        },
        (successMessage) async {
          final isAddedToWatchlist =
              await getWatchListStatus.executed(event.tv.id);

          final currentState = state;
          if (currentState is TvDetailHasData) {
            emit(WatchlistMessageState(successMessage));
            emit(TvDetailHasData(
              result: currentState.result,
              recommendations: currentState.recommendations,
              isAddedToWatchlist: isAddedToWatchlist,
            ));
          }
        },
      );
    });

    on<RemoveFromWatchlistEvent>((event, emit) async {
      final result = await removeWatchlist.executed(event.tv);

      await result.fold(
        (failure) async {
          emit(WatchlistMessageState(failure.message));
        },
        (successMessage) async {
          final isAddedToWatchlist =
              await getWatchListStatus.executed(event.tv.id);

          final currentState = state;
          if (currentState is TvDetailHasData) {
            emit(WatchlistMessageState(successMessage));
            emit(TvDetailHasData(
              result: currentState.result,
              recommendations: currentState.recommendations,
              isAddedToWatchlist: isAddedToWatchlist,
            ));
          }
        },
      );
    });
  }
}
