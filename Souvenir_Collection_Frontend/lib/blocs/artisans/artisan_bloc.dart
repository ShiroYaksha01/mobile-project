import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/artisan_service.dart';
import 'artisan_event.dart';
import 'artisan_state.dart';

class ArtisanBloc extends Bloc<ArtisanEvent, ArtisanState> {
  final ArtisanService _artisanService;

  ArtisanBloc({required ArtisanService artisanService})
      : _artisanService = artisanService,
        super(ArtisanInitial()) {
    on<LoadArtisansRequested>(_onLoadArtisansRequested);
  }

  Future<void> _onLoadArtisansRequested(
    LoadArtisansRequested event,
    Emitter<ArtisanState> emit,
  ) async {
    emit(ArtisanLoading());
    try {
      final artisans = await _artisanService.getAllArtisans();
      emit(ArtisanLoaded(artisans));
    } catch (e) {
      emit(ArtisanError(e.toString()));
    }
  }
}
