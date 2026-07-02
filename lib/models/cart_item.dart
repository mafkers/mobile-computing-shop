import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'title': product.title,
      'price': product.price,
      'image': product.image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['productId'],
        title: map['title'],
        price: map['price'],
        image: map['image'],
        description: '', // Optional for cart
        category: '',    // Optional for cart
      ),
      quantity: map['quantity'],
    );
  }
}
