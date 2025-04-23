import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final int id;
  final int user_id;
  final int restaurant_id;
  final int price;
  final int ship;
  final int discount;
  final int total_amount;
  final String payment;
  final Timestamp? created_at;
  final Timestamp? updated_at;


  const Orders(
      {
        required this.id,
        required this.user_id,
        required this.restaurant_id,
        required this.price,
        required this.ship,
        required this.discount,
        required this.total_amount,
        required this.payment,
        this.created_at,
        this.updated_at,
      });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'restaurant_id': restaurant_id,
      'price': price,
      'ship': ship,
      'discount': discount,
      'total_amount': total_amount,
      'payment': payment,
      'created_at': created_at,
      'updated_at': updated_at};
  }


  Orders.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? 0,
        user_id = map['user_id'] ?? 0,
        restaurant_id = map['restaurant_id'] ?? 0,
        price = map['price'] ?? 0,
        ship = map['ship'] ?? 0,
        discount = map['discount'] ?? 0,
        total_amount = map['total_amount'] ?? 0,
        payment = map['payment'] ?? '',
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;

  @override
  String toString() {
    return 'Orders {id: ${id}, user_id: ${user_id} }';
  }
}