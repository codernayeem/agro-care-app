import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'order_widget.dart';

class OrderListScreen extends StatelessWidget {
  final bool showAnim;
  OrderListScreen({super.key, this.showAnim = false});

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
      body: showAnim
          ? SingleChildScrollView(
              child: Column(
                children: [
                  animView(),
                  ordersList(data_ref, showAnim),
                ],
              ),
            )
          : ordersList(data_ref, false),
    );
  }

  Widget animView() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            'assets/anim/done.json',
            width: 100,
            height: 100,
            repeat: false,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your order is placed',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Text(
            "Your order should be delivered within 5-7 working days",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget ordersList(var data_ref, bool staticPhysics) {
    return FirestorePagination(
        query: data_ref,
        limit: 10,
        viewType: ViewType.list,
        isLive: false,
        shrinkWrap: staticPhysics,
        physics: staticPhysics ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        itemBuilder: (context, documentSnapshot, index) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          data['orderId'] = documentSnapshot.id;
          return OrderWidget(data);
        });
  }
}
