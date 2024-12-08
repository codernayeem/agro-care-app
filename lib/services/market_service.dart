import 'package:agro_care_app/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketService {
  final String userId;
  late DocumentReference<Map<String, dynamic>> cartRef;

  MarketService({required this.userId}) {
    cartRef = FireStoreServices.cartRef(userId);
  }
  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final doc = await cartRef.collection('items').doc(productId).get();
      if (doc.exists) {
        final currentQuantity = doc.data()?['quantity'] ?? 0;
        await cartRef.collection('items').doc(productId).update({
          'quantity': currentQuantity + quantity,
        });
      } else {
        await cartRef.collection('items').doc(productId).set({
          'quantity': quantity,
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    try {
      await cartRef.collection('items').doc(productId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateCart(String productId, int quantity) async {
    try {
      await cartRef.collection('items').doc(productId).update({
        'quantity': quantity,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final items = await cartRef.collection('items').get();
      for (final item in items.docs) {
        await item.reference.delete();
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // orders
  Future<bool> placeOrder(String address) async {
    try {
      final items = await cartRef.collection('items').get();
      var productRef = FireStoreServices.db.collection('products');
      final orderRef = FireStoreServices.db.collection('orders').doc();

      double total = 0;

      final orderItems = <String, dynamic>{};
      for (final item in items.docs) {
        final product = await productRef.doc(item.id).get();
        var x = product.data()!;
        x['quantity'] = item.data()['quantity'];
        total += x['current_price'] * x['quantity'];
        orderItems[item.id] = x;
      }
      await orderRef.set({
        'userId': userId,
        'items': orderItems,
        'status': 'pending',
        'address': address,
        'itemsCount': orderItems.length,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await clearCart();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
