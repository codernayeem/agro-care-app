import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';

import 'order_widget.dart';

class OrderListScreen extends StatelessWidget {
  OrderListScreen({super.key});

  final ref = FireStoreServices.db.collection('orders');

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var data_ref = ref
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: FirestorePagination(
          query: data_ref,
          limit: 10,
          viewType: ViewType.list,
          isLive: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          itemBuilder: (context, documentSnapshot, index) {
            var data = documentSnapshot.data() as Map<String, dynamic>;
            data['orderId'] = documentSnapshot.id;
            return OrderWidget(data);
          }),
    );
  }
}
