import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/bloc/topratedtv/top_rated_tv_bloc.dart';
import 'package:ditonton/presentation/provider/top_rated_tv_notifier.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class TopRatedTvPage extends StatefulWidget {
  static const ROUTE_NAME = '/top-rated-tv';

  @override
  _TopRatedTvPageState createState() => _TopRatedTvPageState();
}

class _TopRatedTvPageState extends State<TopRatedTvPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<TopRatedTvBloc>().add(fetchTopRatedTv()));
    // Provider.of<TopRatedTvNotifier>(context, listen: false)
    //     .fetchTopRatedTv());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Rated Tv'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<TopRatedTvBloc, TopRatedTvState>(
            builder: (context, state) {
              if (state is TopratedTvLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is TopRatedTvHasData) {
                final result = state.result;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final tv = result[index];
                    return TvCard(tv);
                  },
                  itemCount: result.length,
                );
              } else if (state is TopRatedTvError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return Container();
              }
            },
          )
          // Consumer<TopRatedTvNotifier>(
          //   builder: (context, data, child) {
          //     if (data.state == RequestState.Loading) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else if (data.state == RequestState.Loaded) {
          //       return ListView.builder(
          //         itemBuilder: (context, index) {
          //           final tv = data.tv[index];
          //           return TvCard(tv);
          //         },
          //         itemCount: data.tv.length,
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
