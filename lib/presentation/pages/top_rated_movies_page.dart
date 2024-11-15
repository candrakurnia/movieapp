import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/bloc/topratedmovies/top_rated_movies_bloc.dart';
import 'package:ditonton/presentation/provider/top_rated_movies_notifier.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class TopRatedMoviesPage extends StatefulWidget {
  static const ROUTE_NAME = '/top-rated-movie';

  @override
  _TopRatedMoviesPageState createState() => _TopRatedMoviesPageState();
}

class _TopRatedMoviesPageState extends State<TopRatedMoviesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<TopRatedMoviesBloc>().add(fetchTopRatedMovies())
        // Provider.of<TopRatedMoviesNotifier>(context, listen: false)
        //     .fetchTopRatedMovies()
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Rated Movies'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<TopRatedMoviesBloc, TopRatedMoviesState>(
            builder: (context, state) {
              if (state is TopRatedMoviesLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is TopRatedMoviesHasData) {
                final result = state.result;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final movie = result[index];
                    return MovieCard(movie);
                  },
                  itemCount: result.length,
                );
              } else if (state is TopRatedMoviesError) {
                return Expanded(
                  child: Center(
                    child: Text(state.message),
                  ),
                );
              } else {
                return Expanded(
                  child: Container(),
                );
              }
            },
          )
          // Consumer<TopRatedMoviesNotifier>(
          //   builder: (context, data, child) {
          //     if (data.state == RequestState.Loading) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else if (data.state == RequestState.Loaded) {
          //       return ListView.builder(
          //         itemBuilder: (context, index) {
          //           final movie = data.movies[index];
          //           return MovieCard(movie);
          //         },
          //         itemCount: data.movies.length,
          //       );
          //     } else {
          //       return Center(
          //         key: Key('error_message'),
          //         child: Text(data.message),
          //       );
          //     }
          //   },
          // ),
          ),
    );
  }
}
