part of 'on_airing_tv_bloc.dart';

sealed class OnairingtvEvent extends Equatable {
  const OnairingtvEvent();

  @override
  List<Object> get props => [];
}

class fetchOnAiring extends OnairingtvEvent {}
