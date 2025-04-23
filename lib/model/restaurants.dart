import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurants {
  final int id;
  final String? name;
  final String? address;
  final String? phone;
  final String? opening_hours;
  final int? total_rate;
  final int? review_count;
  final Timestamp? created_at;
  final Timestamp? updated_at;


  const Restaurants(
      {
        required this.id,
        this.name,
        this.address,
        this.phone,
        this.opening_hours,
        this.total_rate,
        this.review_count,
        this.created_at,
        this.updated_at,
      });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'opening_hours': opening_hours,
      'total_rate': total_rate,
      'review_count': review_count,
      'created_at': created_at,
      'updated_at': updated_at};
  }


  Restaurants.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ?? '',
        address = map['address'] ?? '',
        phone = map['phone'] ?? '',
        opening_hours = map['opening_hours'] ?? '',
        total_rate = map['total_rate'] ?? null,
        review_count = map['review_count'] ?? null,
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;

  @override
  String toString() {
    return 'Restaurants {id: $id, name: $name, address: $address, phone: $phone, opening_hours: $opening_hours, created_at: $created_at, updated_at: $updated_at}';
  }
}