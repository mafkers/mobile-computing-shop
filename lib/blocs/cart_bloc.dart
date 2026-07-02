import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/db_helper.dart';

// --- EVENTS ---
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class LoadCartEvent extends CartEvent {}
class AddToCartEvent extends CartEvent {
  final Product product;
  const AddToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}
class RemoveFromCartEvent extends CartEvent {
  final int productId;
  const RemoveFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}
class ClearCartEvent extends CartEvent {}

// --- STATES ---
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState {
  final List<CartItem> items;
  const CartLoaded(this.items);
  
  double get totalPrice => items.fold(0, (total, current) => total + (current.product.price * current.quantity));
  
  @override
  List<Object> get props => [items];
}
class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<LoadCartEvent>((event, emit) async {
      emit(CartLoading());
      try {
        final items = await DatabaseHelper.instance.getCartItems();
        emit(CartLoaded(items));
      } catch (e) {
        emit(CartError("Failed to load cart: $e"));
      }
    });

    on<AddToCartEvent>((event, emit) async {
      try {
        // Check if item already exists
        final items = await DatabaseHelper.instance.getCartItems();
        final existingItem = items.where((item) => item.product.id == event.product.id).toList();
        
        if (existingItem.isNotEmpty) {
          final item = existingItem.first;
          item.quantity += 1;
          await DatabaseHelper.instance.addToCart(item);
        } else {
          await DatabaseHelper.instance.addToCart(CartItem(product: event.product));
        }
        
        final newItems = await DatabaseHelper.instance.getCartItems();
        emit(CartLoaded(newItems));
      } catch (e) {
        emit(CartError("Failed to add to cart: $e"));
      }
    });

    on<RemoveFromCartEvent>((event, emit) async {
      try {
        await DatabaseHelper.instance.removeFromCart(event.productId);
        final items = await DatabaseHelper.instance.getCartItems();
        emit(CartLoaded(items));
      } catch (e) {
        emit(CartError("Failed to remove from cart: $e"));
      }
    });
    
    on<ClearCartEvent>((event, emit) async {
      try {
        await DatabaseHelper.instance.clearCart();
        emit(const CartLoaded([]));
      } catch (e) {
        emit(CartError("Failed to clear cart: $e"));
      }
    });
  }
}
