import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  OrderListScreen({super.key});

  final ref = FireStoreServices.db.collection('orders');

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var data_ref = ref.where('userId', isEqualTo: userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('my Orders',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: FirestorePagination(
          query: data_ref,
          limit: 10,
          viewType: ViewType.list,
          physics: const NeverScrollableScrollPhysics(),
          isLive: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          itemBuilder: (context, documentSnapshot, index) {
            var data = documentSnapshot.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['itemsCount'].toString()),
                subtitle: Text(data['status']),
                trailing: Text(data['total'].toString()),
              ),
            );
          }),
    );
  }
}
