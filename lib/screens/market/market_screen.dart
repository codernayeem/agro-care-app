import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var ref = FireStoreServices.db.collection('products');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
      ),
      body: Padding(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  // Tell FirestoreQueryBuilder to try to obtain more items.
                  // It is safe to call this function from within the build method.
                  snapshot.fetchMore();
                }
                final product =
                    Product.fromFirestore(snapshot.docs[index].data());
                return MiniProductCard(product: product);
              },
            );
          },
        ),
      ),
      // body: FirestoreListView<Map<String, dynamic>>(
      //   query: ref,
      //   emptyBuilder: (context) {
      //     return const Center(
      //       child: Text('No products found'),
      //     );
      //   },
      //   itemBuilder: (context, snapshot) {
      //     final product = Product.fromFirestore(snapshot.data());
      //     return MiniProductCard(product: product);
      //   },
      // ),
    );
  }
}

class MiniProductCard extends StatelessWidget {
  final Product product;
  const MiniProductCard({required this.product, Key? key}) : super(key: key);

  Future<bool> addToCart(BuildContext context) async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0.0, 8.0),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {},
          splashColor: AppColors.primaryDarkColor.withOpacity(.08),
          child: Stack(children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(6)),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              imageUrl: product.imageUrl,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 8, 2),
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          fontFamily: 'SanFranciscoLight',
                          color: Colors.black87,
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 8, 2),
                    child: Text(
                      product.category,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      product.originalPrice != product.currentPrice
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text(
                                "${product.originalPrice}৳",
                                maxLines: 1,
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            product.originalPrice != product.currentPrice
                                ? 4
                                : 8,
                            0,
                            0,
                            0),
                        child: Text(
                          "${product.currentPrice}৳",
                          maxLines: 1,
                          style: const TextStyle(
                              color: AppColors.primaryDarkColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 0, right: 4, bottom: 4),
                        child: InkWell(
                          onTap: () async {
                            addToCart(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primaryDarkColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ]),
        ),
      ),
    );
  }
}
