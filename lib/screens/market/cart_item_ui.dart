import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CartItemUI extends StatelessWidget {
  final int quantity;
  final void Function(String) onPressDelete;
  final Product cartProduct;

  const CartItemUI({
    super.key,
    required this.onPressDelete,
    required this.cartProduct,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(right: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Image.asset(
                    'assets/images/placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                  imageUrl: cartProduct.imageUrl,
                  fit: BoxFit.cover,
                ))),
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          cartProduct.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              fontFamily: "SanfranciscoLight",
                              letterSpacing: 1.05,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          cartProduct.category,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 10,
                              fontFamily: "SanfranciscoLight",
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () {
                        onPressDelete(cartProduct.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 122, 117, 117)
                              .withOpacity(0.09),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7)),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 122, 117, 117),
                          size: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        '৳${cartProduct.currentPrice}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${quantity}x',
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 12),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
