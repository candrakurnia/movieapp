import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:ditonton/domain/usecases/search_tv.dart';
import 'package:flutter/foundation.dart';

class MovieSearchNotifier extends ChangeNotifier {
  final SearchMovies searchMovies;
  // final SearchTv searchTv;

  MovieSearchNotifier({required this.searchMovies});

  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  List<Movie> _searchResult = [];
  List<Movie> get searchResult => _searchResult;

  // List<Tv> _searchTvResult = [];
  // List<Tv> get searchTvResult => _searchTvResult;

  String _message = '';
  String get message => _message;

  Future<void> fetchMovieSearch(String query) async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await searchMovies.execute(query);
    result.fold(
      (failure) {
        _message = failure.message;
        _state = RequestState.Error;
        notifyListeners();
      },
      (data) {
        _searchResult = data;
        _state = RequestState.Loaded;
        notifyListeners();
      },
    );
  }
  // Future<void> fetchTvSearch(String query) async {
  //   _state = RequestState.Loading;
  //   notifyListeners();

  //   final result = await searchTv.execute(query);
  //   result.fold(
  //     (failure) {
  //       _message = failure.message;
  //       _state = RequestState.Error;
  //       notifyListeners();
  //     },
  //     (data) {
  //       _searchTvResult = data;
  //       _state = RequestState.Loaded;
  //       notifyListeners();
  //     },
  //   );
  // }
}
