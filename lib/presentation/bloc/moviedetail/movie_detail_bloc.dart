import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/presentation/bloc/moviedetail/movie_detail_event.dart';
import 'package:ditonton/presentation/bloc/moviedetail/movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetMovieDetail getMovieDetail;
  final GetMovieRecommendations getMovieRecommendations;
  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;

  MovieDetailBloc({
    required this.getMovieDetail,
    required this.getMovieRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(MovieDetailInitial()) {
    on<FetchMovieDetailEvent>((event, emit) async {
      emit(MovieDetailLoading());
      final detailResult = await getMovieDetail.execute(event.id);
      final recommendationResult =
          await getMovieRecommendations.execute(event.id);
      await detailResult.fold(
        (failure) async {
          emit(MovieDetailError(failure.message));
        },
        (movie) async {
          final recommendationState =
              await recommendationResult.fold<List<Movie>>(
            (failure) => <Movie>[],
            (recommendations) => recommendations,
          );

          final isAddedToWatchlist = await getWatchListStatus.execute(event.id);

          emit(MovieDetailLoaded(
            movie: movie,
            recommendations: recommendationState,
            isAddedToWatchlist: isAddedToWatchlist,
          ));
        },
      );
    });

    on<AddToWatchlistEvent>((event, emit) async {
      final result = await saveWatchlist.execute(event.movie);

      await result.fold(
        (failure) async {
          emit(WatchlistMessageState(failure.message));
        },
        (successMessage) async {
          final isAddedToWatchlist =
              await getWatchListStatus.execute(event.movie.id);

          final currentState = state;
          if (currentState is MovieDetailLoaded) {
            emit(WatchlistMessageState(successMessage));
            emit(MovieDetailLoaded(
              movie: currentState.movie,
              recommendations: currentState.recommendations,
              isAddedToWatchlist: isAddedToWatchlist,
            ));
          }
        },
      );
    });

    on<RemoveFromWatchlistEvent>((event, emit) async {
      final result = await removeWatchlist.execute(event.movie);

      await result.fold(
        (failure) async {
          emit(WatchlistMessageState(failure.message));
        },
        (successMessage) async {
          final isAddedToWatchlist =
              await getWatchListStatus.execute(event.movie.id);

          final currentState = state;
          if (currentState is MovieDetailLoaded) {
            emit(WatchlistMessageState(successMessage));
            emit(MovieDetailLoaded(
              movie: currentState.movie,
              recommendations: currentState.recommendations,
              isAddedToWatchlist: isAddedToWatchlist,
            ));
          }
        },
      );
    });
    // on<LoadWatchlistStatusEvent>((event, emit) async {
    //   final isAddedToWatchlist = await getWatchListStatus.execute(event.id);
    //   emit(MovieDetailLoading());
    //   emit(WatchlistStatusLoaded(isAddedToWatchlist));
    // });
  }
}
