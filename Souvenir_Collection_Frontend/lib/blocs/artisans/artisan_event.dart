import 'package:equatable/equatable.dart';

abstract class ArtisanEvent extends Equatable {
  const ArtisanEvent();

  @override
  List<Object?> get props => [];
}

class LoadArtisansRequested extends ArtisanEvent {}
