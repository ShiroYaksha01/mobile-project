import 'package:equatable/equatable.dart';
import '../../models/artisan.dart';

abstract class ArtisanState extends Equatable {
  const ArtisanState();

  @override
  List<Object?> get props => [];
}

class ArtisanInitial extends ArtisanState {}

class ArtisanLoading extends ArtisanState {}

class ArtisanLoaded extends ArtisanState {
  final List<Artisan> artisans;

  const ArtisanLoaded(this.artisans);

  @override
  List<Object?> get props => [artisans];
}

class ArtisanError extends ArtisanState {
  final String message;

  const ArtisanError(this.message);

  @override
  List<Object?> get props => [message];
}
