import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/shimmer_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_card.dart';

class ProductRow extends StatefulWidget {
  final String title;
  final String category;
  final int maxItem;
  final int flag;
  final void Function() onSeeAll;

  static int BEST_SELLING = 0;
  static int NEW_PRODUCTS = 1;
  static int CATEGORY = 2;

  const ProductRow({
    super.key,
    required this.title,
    required this.maxItem,
    required this.onSeeAll,
    required this.flag,
    this.category = '',
  });

  @override
  State<ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<ProductRow> {
  var ref;

  @override
  void initState() {
    super.initState();

    ref = FireStoreServices.db.collection('products');

    if (widget.flag == ProductRow.BEST_SELLING) {
      ref = ref.orderBy('sold_count', descending: true).limit(widget.maxItem);
    } else if (widget.flag == ProductRow.NEW_PRODUCTS) {
      ref = ref.orderBy('created_at', descending: true).limit(widget.maxItem);
    } else if (widget.flag == ProductRow.CATEGORY) {
      ref = ref
          .where('category', isEqualTo: widget.category)
          .limit(widget.maxItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  widget.onSeeAll();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(60, 181, 203, 236),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
        buildProductList(),
      ],
    );
  }

  Widget buildProductList() {
    return StreamBuilder(
      stream: ref.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerHelper()
              .buildProductRowShimmer(itemCount: 3, height: 150);
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "Some Error Occurred. Please refresh & try again",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "No Product to show",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          );
        }
        var products = snapshot.data!.docs;
        return SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = Product.fromFirestore(
                  products[index].data() as Map<String, dynamic>);
              return Container(
                width: 150,
                padding: const EdgeInsets.only(bottom: 16.0, top: 8),
                child: MiniProductCard(
                  product: product,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8.0);
            },
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      },
    );
  }
}
