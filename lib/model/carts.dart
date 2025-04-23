import 'package:cloud_firestore/cloud_firestore.dart';

class Carts {
  final int id;
  final int user_id;
  final int item_id;
  final int restaurant_id;
  final int quantity;
  final Timestamp? created_at;
  final Timestamp? updated_at;


  const Carts(
      {
        required this.id,
        required this.user_id,
        required this.item_id,
        required this.restaurant_id,
        required this.quantity,
        this.created_at,
        this.updated_at,
      });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'item_id': item_id,
      'restaurant_id': restaurant_id,
      'quantity': quantity,
      'created_at': created_at,
      'updated_at': updated_at};
  }


  Carts.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        user_id = map['user_id'] ?? '',
        item_id = map['item_id'] ?? '',
        restaurant_id = map['restaurant_id'],
        quantity = map['quantity'] ?? '',
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;

  @override
  String toString() {
    return 'Carts {id: $id, user_id: $user_id, item_id: $item_id, restaurant_id: $restaurant_id, quantity: $quantity, created_at: $created_at, updated_at: $updated_at}';
  }
}