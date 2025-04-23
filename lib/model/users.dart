import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final int id;
  final String name;
  final String ? password;
  final String email;
  final String ? phone;
  final String ? address;
  final String role;
  final String ? imageURL;
  final int level;
  final int coin;
  final Timestamp? created_at;
  final Timestamp? updated_at;

  const Users(
   {
     required this.id,
     required this.name,
      this.password,
     required this.email,
      this.phone,
      this.address,
     required this.role,
      this.imageURL,
     required this.level,
     required this.coin,
     this.created_at,
     this.updated_at,
  });

  // Chuyển đổi đối tượng Task thành Map
  Map<String, Object?> toMap() {
    return {
      'user_id': id,
      'name': name,
      'password': password,
      'email': email,
      'phone': phone,
      'address': address,
      'type': role,
      'imageURL': imageURL,
      'level': level,
      'coin': coin,
      'created_at': created_at,
      'updated_at': updated_at};
  }

  // Tạo đối tượng Task từ Map
  Users.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ?? '',
        password = map['password'] ?? '',
        email = map['email'] ?? '',
        phone = map['phone'] ?? '',
        address = map['address'] ?? '',
        role = map['role'] ?? '',
        imageURL = map['imageURL'] ?? '',
        level = map['level'] ?? null,
        coin = map['coin'] ?? null,
        created_at = (map['created_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['created_at'])) : null,
        updated_at = (map['updated_at'] != null) ? Timestamp.fromDate(DateTime.parse(map['updated_at'])) : null;
  @override
  String toString() {
    return 'Users {id: $id, name: $name, address: $address, phone: $phone}';
  }
}