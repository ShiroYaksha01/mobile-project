import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_state.dart';

export 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState(favoriteIds: {}));

  void toggle(String productId) {
    final ids = Set<String>.from(state.favoriteIds);
    if (ids.contains(productId)) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    emit(FavoritesState(favoriteIds: ids));
  }

  void setFavorites(Set<String> ids) {
    emit(FavoritesState(favoriteIds: ids));
  }

  bool isFavorite(String productId) => state.favoriteIds.contains(productId);
}
