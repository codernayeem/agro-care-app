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
      FireStoreServices.db
          .collection('carts')
          .doc(auth.currentUser!.uid)
          .collection('items')
          .count()
          .get()
          .then((value) {
        print(value.count);
        cartItemsCount = value.count!;
        notifyListeners();
      });
    } else {
      cartItemsCount = 0;
      notifyListeners();
    }
  }
}
