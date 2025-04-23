import 'package:cloud_firestore/cloud_firestore.dart';

class Reviews {
  final int id;
  final int restaurant_id;
  final int user_id;
  final int rating;
  final String comment;
  final int order_id;
  final Timestamp? created_at;
  final Timestamp? updated_at;


  const Reviews(
      {
        required this.id,
        required this.restaurant_id,
        required this.user_id,
        required this.rating,
        required this.comment,
        required this.order_id,
        this.created_at,
        this.updated_at,
      });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurant_id,
      'user_id': user_id,
      'rating': rating,
      'comment': comment,
      'order_id': order_id,
      'created_at': created_at,
      'updated_at': updated_at};
  }


  Reviews.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? 0,
        restaurant_id = map['restaurant_id'] ?? 0,
        user_id = map['user_id'] ?? 0,
        rating = map['rating'] ?? 0,
        comment = map['comment'] ?? '',
        order_id = map['order_id'] ?? 0,
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;


  @override
  String toString() {
    return 'Reviews {id: $id, user_id: $user_id, rating: $rating, restaurant_id: $restaurant_id, comment: $comment, order_id: $order_id, created_at: $created_at, updated_at: $updated_at}';
  }
}