import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_state.dart';

export 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(cartCount: 0));

  void setCount(int count) {
    emit(CartState(cartCount: count));
  }

  void increment() {
    emit(CartState(cartCount: state.cartCount + 1));
  }

  void decrement() {
    final newCount = state.cartCount > 0 ? state.cartCount - 1 : 0;
    emit(CartState(cartCount: newCount));
  }
}
