import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../utils/db_helper.dart';

// --- EVENTS ---
abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoriteEvent {}
class ToggleFavoriteEvent extends FavoriteEvent {
  final Product product;
  const ToggleFavoriteEvent(this.product);
  @override
  List<Object> get props => [product];
}

// --- STATES ---
abstract class FavoriteState extends Equatable {
  const FavoriteState();
  @override
  List<Object> get props => [];
}

class FavoriteInitial extends FavoriteState {}
class FavoriteLoading extends FavoriteState {}
class FavoriteLoaded extends FavoriteState {
  final List<Product> favorites;
  const FavoriteLoaded(this.favorites);
  @override
  List<Object> get props => [favorites];
}
class FavoriteError extends FavoriteState {
  final String message;
  const FavoriteError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavoritesEvent>((event, emit) async {
      emit(FavoriteLoading());
      try {
        final favorites = await DatabaseHelper.instance.getFavorites();
        emit(FavoriteLoaded(favorites));
      } catch (e) {
        emit(FavoriteError("Failed to load favorites: $e"));
      }
    });

    on<ToggleFavoriteEvent>((event, emit) async {
      try {
        final favorites = await DatabaseHelper.instance.getFavorites();
        final isFavorite = favorites.any((p) => p.id == event.product.id);
        
        if (isFavorite) {
          await DatabaseHelper.instance.removeFavorite(event.product.id);
        } else {
          await DatabaseHelper.instance.addFavorite(event.product);
        }
        
        final updatedFavorites = await DatabaseHelper.instance.getFavorites();
        emit(FavoriteLoaded(updatedFavorites));
      } catch (e) {
        emit(FavoriteError("Failed to toggle favorite: $e"));
      }
    });
  }
}
