import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../model/firebaseModel.dart';

class FirebaseController {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference firebaseModelRef;

  FirebaseController(){
    firebaseModelRef = _firestore.collection('wait');
  }

  Stream<List<FirebaseModel>> getAll(int customerId) {
    return firebaseModelRef.where('customer.cus_id', isEqualTo: customerId).where('status', isNotEqualTo: 'Hoàn thành').snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) {
      try {
        final firebaseModels = docs.map((doc) => FirebaseModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
        if (firebaseModels.isEmpty) {
          print("empty");
          return [];
        } else {

          //print(firebaseModelListToString(firebaseModels));
          return firebaseModels;
        }
      } catch (e) {
        print('Error converting FirebaseModel: $e');
        return [];
      }
    });
  }

  Stream<List<FirebaseModel>> getOrdered(int customerId, String status) {
    return firebaseModelRef.where('customer.cus_id', isEqualTo: customerId)
        .where('status', isEqualTo: status).snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) {
      try {
        final firebaseModels = docs.map((doc) => FirebaseModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
        if (firebaseModels.isEmpty) {
          return [];
        } else {
          return firebaseModels;
        }
      } catch (e) {
        print('Error converting FirebaseModel: $e');
        return [];
      }
    });
  }

  String firebaseModelListToString(List<FirebaseModel> models) {
    if (models.isEmpty) {
      return "Không có dữ liệu";
    } else {
      final result = models.map((model) => model.toString()).join(", ");
      return "[$result]";
    }
  }

  Future<void> saveDataToFirebase(FirebaseModel data) async {
    try {
      await firebaseModelRef.add(data.toMap());
      // Lưu dữ liệu vào Cloud Firestore
      print('Data saved to Firebase.');
    } catch (error) {
      print('Failed to save data to Firebase: $error');
    }
  }
}