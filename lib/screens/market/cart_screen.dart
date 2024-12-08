import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/providers/cart_provider.dart';
import 'package:agro_care_app/screens/market/address_ui.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/services/market_service.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/no_item.dart';
import '../../widgets/shimmer_helper.dart';

import 'cart_item_ui.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CollectionReference cartRef;
  late MarketService marketService;

  bool isReady = false;
  bool isError = false;

  double totalCost = 0.0;
  List<Product> cartProducts = [];

  @override
  void initState() {
    super.initState();
    var userId = FirebaseAuth.instance.currentUser!.uid;
    cartRef = FireStoreServices.db
        .collection('carts')
        .doc(userId)
        .collection('items');
    marketService = MarketService(userId: userId);
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      cartProducts.clear();
      totalCost = 0.0;
      isReady = false;
      isError = false;
    });
    try {
      final cartSnapshot = await cartRef.get();
      List<Product> products = [];

      for (var item in cartSnapshot.docs) {
        String productId = item.id;
        int quantity = item['quantity'];

        // Fetch product details to get the price
        final productSnapshot = await FireStoreServices.db
            .collection('products')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          products.add(Product.fromFirestore(productSnapshot.data()!, productId,
              quantity: quantity));
        }
      }

      double total = 0.0;
      for (var product in products) {
        total += product.currentPrice * product.quantity;
      }

      setState(() {
        cartProducts = products;
        totalCost = total;
        isReady = true;
        isError = false;
      });
    } catch (e) {
      setState(() {
        isReady = true;
        isError = true;
      });
    }
  }

  Future<double> calculateTotalCost() async {
    double total = 0.0;
    final cartSnapshot = await cartRef.get();

    for (var item in cartSnapshot.docs) {
      String productId = item.id;
      int quantity = item['quantity'];

      // Fetch product details to get the price
      final productSnapshot = await FireStoreServices.db
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        double price = (productSnapshot['current_price'] as num).toDouble();
        total += price * quantity;
      }
    }

    return total;
  }

  Future<String> chooseAddress() async {
    // a bottom sheet to choose address (a text field to enter address)
    var res = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return const AddressModal();
      },
    );
    if (res != null && res.isNotEmpty) {
      return res;
    }
    return '';
  }

  void onPressProceedToShipping() async {
    if (cartProducts.isEmpty) {
      return;
    }
    String address = await chooseAddress();
    if (address.isNotEmpty) {
      if (await marketService.placeOrder(address)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully.'),
          ),
        );
        context.read<CartProvider>().getCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order.'),
          ),
        );
      }
    }
  }

  Container buildBottomContainer(int count, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            width: MediaQuery.of(context).size.width,
            child: FilledButton.tonalIcon(
              onPressed: () {
                onPressProceedToShipping();
              },
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 72, 166, 69),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.shopping_cart),
              ),
              label: Row(
                children: [
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "${count} Items",
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        "৳$total",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: "SanfranciscoLight"),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  const Spacer(),
                  const Text("Place Orders ➤", style: TextStyle(fontSize: 13)),
                ],
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.primaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryColor,
              backgroundColor: Colors.white,
              onRefresh: fetchCartItems,
              child: isReady
                  ? isError
                      ? const Center(child: Text('Failed to load cart items.'))
                      : cartProducts.isEmpty
                          ? const NoItemWidget(msg: "Your cart is empty")
                          : CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(8),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final product = cartProducts[index];
                                        return CartItemUI(
                                          quantity: product.quantity,
                                          cartProduct: product,
                                          onPressDelete: (id) async {
                                            if (await marketService
                                                .removeFromCart(id)) {
                                              context
                                                  .read<CartProvider>()
                                                  .getCount();
                                              fetchCartItems();
                                            }
                                          },
                                        );
                                      },
                                      childCount: cartProducts.length,
                                    ),
                                  ),
                                ),
                              ],
                            )
                  : ShimmerHelper()
                      .buildListShimmer(item_count: 10, item_height: 100.0),
            ),
          ),
          buildBottomContainer(cartProducts.length, totalCost),
        ],
      ),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: cartRef.snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       return const Center(child: Text('Something went wrong.'));
      //     }

      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return ShimmerHelper()
      //           .buildListShimmer(item_count: 10, item_height: 100.0);
      //     }

      //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      //       return const Center(child: Text('Your cart is empty.'));
      //     }

      //     return FutureBuilder<double>(
      //       future: calculateTotalCost(),
      //       builder: (context, totalSnapshot) {
      //         return Column(
      //           children: [
      //             const SizedBox(height: 14),
      //             Expanded(
      //               child: Container(
      //                 padding: const EdgeInsets.all(8),
      //                 margin: const EdgeInsets.symmetric(horizontal: 12),
      //                 decoration: BoxDecoration(
      //                   color: Colors.white,
      //                   borderRadius: BorderRadius.circular(6),
      //                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
      //                   boxShadow: [
      //                     BoxShadow(
      //                       color: Colors.black.withOpacity(0.1),
      //                       spreadRadius: 1,
      //                       blurRadius: 3,
      //                       offset: const Offset(0, 0),
      //                     ),
      //                   ],
      //                 ),
      //                 child: ListView(
      //                   children: snapshot.data!.docs.map((cartItem) {
      //                     return CartItemUiFuture(
      //                       productId: cartItem.id,
      //                       quantity: cartItem['quantity'],
      //                       onPressDelete: (id) async {
      //                         if (await marketService.removeFromCart(id)) {
      //                           ScaffoldMessenger.of(context).showSnackBar(
      //                             const SnackBar(
      //                               content: Text('Item removed from cart.'),
      //                             ),
      //                           );
      //                           context.read<CartProvider>().getCount();
      //                         }
      //                       },
      //                     );
      //                   }).toList(),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 14),
      //             buildBottomContainer(
      //                 snapshot.data!.docs.length, totalSnapshot.data ?? 0.0),
      //           ],
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}

// class CartItemUiFuture extends StatelessWidget {
//   final String productId;
//   final int quantity;
//   final void Function(String) onPressDelete;

//   const CartItemUiFuture(
//       {Key? key,
//       required this.productId,
//       required this.quantity,
//       required this.onPressDelete})
//       : super(key: key);

//   Future<Map<String, dynamic>?> fetchProductDetails() async {
//     final productSnapshot =
//         await FireStoreServices.db.collection('products').doc(productId).get();

//     if (productSnapshot.exists) {
//       return productSnapshot.data();
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: fetchProductDetails(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const ListTile(title: Text('Loading...'));
//         }

//         if (!snapshot.hasData) {
//           return const ListTile(title: Text('Product not found.'));
//         }

//         return CartItemUI(
//           quantity: quantity,
//           cartProduct: Product.fromFirestore(snapshot.data!, productId),
//           onPressDelete: (id) {
//             onPressDelete(id);
//           },
//         );
//       },
//     );
//   }
// }
