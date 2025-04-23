import 'package:cloud_firestore/cloud_firestore.dart';

class Dishes {
  final int id;
  final int restaurant_id;
  final String name;
  final dynamic img;
  final int price;
  final int? rate;
  final String type;
  final Timestamp? created_at;
  final Timestamp? updated_at;


  const Dishes(
      {
        required this.id,
        required this.restaurant_id,
        required this.name,
        required this.img,
        required this.price,
        this.rate,
        required this.type,
        this.created_at,
        this.updated_at,
      });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurant_id,
      'name': name,
      'img': img,
      'price': price,
      'rate': rate,
      'type': type,
      'created_at': created_at,
      'updated_at': updated_at};
  }


  Dishes.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        restaurant_id = map['restaurant_id'],
        name = map['name'] ?? '',
        img = map['img'] != null ? map['img'].toString() : '',
        price = map['price'] ?? '',
        rate = map['rate'] ?? '',
        type = map['type'] ?? '',
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;

  @override
  String toString() {
    return 'Dishes {id: $id, restaurant_id: $restaurant_id, name: $name, img: $img, price: $price, rate: $rate,type: $type, created_at: $created_at, updated_at: $updated_at}';
  }
}