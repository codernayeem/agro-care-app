import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/product_model.dart';
import '../screens/market/product_details.dart';
import '../theme/colors.dart';

class MiniProductCard extends StatelessWidget {
  final Product product;
  final bool biggerAddButton;
  const MiniProductCard(
      {required this.product, Key? key, this.biggerAddButton = false})
      : super(key: key);

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
            spreadRadius: 2,
            offset: const Offset(0.0, 1),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ProductDetailsScreen(productID: product.id);
                },
              ),
            );
          },
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
                              placeholder: (context, url) => Image.asset(
                                'assets/images/placeholder.jpg',
                                fit: BoxFit.cover,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          product.originalPrice != product.currentPrice
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
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
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Text(
                              "${product.currentPrice}৳",
                              maxLines: 1,
                              style: const TextStyle(
                                  color: AppColors.primaryDarkColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 0, right: 6, bottom: 6),
                        child: OutlinedButton(
                          onPressed: () async {
                            addToCart(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            minimumSize: const Size(0, 24),
                            primary: AppColors.darkGreen,
                            side: const BorderSide(
                                color: AppColors.darkGreen, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
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
