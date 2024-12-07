import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  int cartItemsCount = 0;

  var auth = FirebaseAuth.instance;

  void initialize() {
    auth.authStateChanges().listen((User? user) {
      getCount();
      notifyListeners();
    });
  }

  void getCount() {
    if (auth.currentUser != null) {
      var ref = FireStoreServices.db;

      ref.collection('cart').doc(auth.currentUser!.uid).get().then((value) {
        if (value.data() != null && value.data()!['cartItemsCount'] != null) {
          cartItemsCount = value.data()!['cartItemsCount'];
        } else {
          cartItemsCount = 0;
        }
        notifyListeners();
      });
    } else {
      cartItemsCount = 0;
      notifyListeners();
    }
  }
}
