import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  static const CATEGORY = 0;
  static const NEW_PRODUCTS = 1;
  static const BEST_SELLING = 2;

  final int flag;
  final String title;
  final String category;
  final bool canSort;

  const ProductListScreen(
      {super.key,
      required this.flag,
      required this.title,
      this.category = '',
      this.canSort = false});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  var ref;
  var original_ref;

  var sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
  ];

  var selectedSortOption = 'Default';

  @override
  void initState() {
    super.initState();
    switch (widget.flag) {
      case ProductListScreen.CATEGORY:
        ref = FireStoreServices.db
            .collection('products')
            .where('category', isEqualTo: widget.category);
        break;
      case ProductListScreen.NEW_PRODUCTS:
        ref = FireStoreServices.db
            .collection('products')
            .orderBy('created_at', descending: true);
        break;
      case ProductListScreen.BEST_SELLING:
        ref = FireStoreServices.db
            .collection('products')
            .orderBy('sold_count', descending: true);
        break;
    }
    original_ref = ref;
  }

  void onSortOptionChanged(String value) {
    setState(() {
      selectedSortOption = value;
      switch (value) {
        case 'Price: Low to High':
          ref = original_ref.orderBy('current_price');
          break;
        case 'Price: High to Low':
          ref = original_ref.orderBy('current_price', descending: true);
          break;
        default:
          ref = original_ref;
      }
    });
  }

  void onPressSort() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions
                .map((e) => RadioListTile(
                      title: Text(e),
                      value: e,
                      groupValue: selectedSortOption,
                      onChanged: (value) {
                        onSortOptionChanged(value.toString());
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (widget.canSort)
            IconButton(
              icon: Image.asset(
                "assets/icons/sort.png",
                color: Colors.white,
                height: 24,
              ),
              onPressed: () {
                onPressSort();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FirestoreQueryBuilder<Map<String, dynamic>>(
                query: ref,
                builder: (context, snapshot, _) {
                  if (snapshot.isFetching) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.docs.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        // Tell FirestoreQueryBuilder to try to obtain more items.
                        // It is safe to call this function from within the build method.
                        snapshot.fetchMore();
                      }
                      final product =
                          Product.fromFirestore(snapshot.docs[index].data());
                      return MiniProductCard(
                          product: product, biggerAddButton: true);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
