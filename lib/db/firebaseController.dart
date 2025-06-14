import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../model/firebaseModel.dart';

class FirebaseController {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference firebaseModelRef;

  FirebaseController(){
    firebaseModelRef = _firestore.collection('wait');
  }

  Stream<List<FirebaseModel>> getAll(int customerId, String status) {
    return firebaseModelRef.where('customer.cus_id', isEqualTo: customerId).snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) {
      try {
        final firebaseModels = docs.map((doc) => FirebaseModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

        // lọc ra những dữ liệu có status khác với status truyền vào
        firebaseModels.removeWhere((firebaseModel) => firebaseModel.status == status);

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