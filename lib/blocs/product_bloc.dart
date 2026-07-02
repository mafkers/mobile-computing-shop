import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

// --- EVENTS ---
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class FetchProductsEvent extends ProductEvent {}

class FetchProductsByCategoryEvent extends ProductEvent {
  final String category;
  const FetchProductsByCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent(this.query);
  @override
  List<Object> get props => [query];
}

// --- STATES ---
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);
  @override
  List<Object> get props => [products];
}
class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<FetchProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.getProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError("Failed to load products: $e"));
      }
    });

    on<FetchProductsByCategoryEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.getProductsByCategory(event.category);
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError("Failed to load products: $e"));
      }
    });

    on<SearchProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        if (event.query.isEmpty) {
          final products = await repository.getProducts();
          emit(ProductLoaded(products));
        } else {
          final products = await repository.searchProducts(event.query);
          emit(ProductLoaded(products));
        }
      } catch (e) {
        emit(ProductError("Failed to search products: $e"));
      }
    });
  }
}
