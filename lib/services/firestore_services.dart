import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServices {
  static DocumentReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('api').doc('v2');

  static DocumentReference<Map<String, dynamic>> communityRef() {
    return db.collection('community').doc('data');
  }
}
