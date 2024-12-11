import 'dart:async';

import 'package:agro_care_app/screens/market/product_list_screen.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/services/market_service.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/product_row.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/quantity_price.dart';
import '../../widgets/shimmer_helper.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productID;

  const ProductDetailsScreen({Key? key, required this.productID})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double appbarOpacity = 0;

  late Product product;
  bool isReady = false;

  Widget productImageView(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        placeholder: (context, url) => Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
        ),
        imageUrl: url,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    var ref = FireStoreServices.db.collection('products').doc(widget.productID);
    var r = await ref.get();
    product = Product.fromFirestore(r.data()!, r.id);
    setState(() {
      isReady = true;
    });
  }

  Future<bool> _onPageRefresh() async {
    setState(() {
      isReady = false;
    });
    await loadProduct();
    return true;
  }

  Future<bool> onPressAddToCart(int quantity) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      showLoginWarning();
      return false;
    }
    String userId = auth.currentUser!.uid;

    MarketService marketService = MarketService(userId: userId);
    try {
      if (await marketService.addToCart(product.id, quantity)) {
        Fluttertoast.showToast(
          msg: 'Product added to cart',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        context.read<CartProvider>().getCount();
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to add to cart',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 175, 76, 76),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  showLoginWarning() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to login'),
          actions: [
            TextButton(
              onPressed: () {
                GoRouter.of(context).push('/auth/login');
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
        body: SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        onRefresh: _onPageRefresh,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(appbarOpacity),
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        CupertinoIcons.arrow_left,
                        color: Colors.black87,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              expandedHeight: 350.0,
              flexibleSpace: FlexibleSpaceBar(
                background:
                    isReady ? productImageView(product.imageUrl) : Container(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                  border: Border.all(
                      color: Colors.indigo[400]!.withOpacity(0.2),
                      width: 1.0,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 10,
                      spreadRadius: 0.0,
                      offset: const Offset(0.0, 10.0),
                    )
                  ],
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 14, left: 12, right: 12),
                      child: isReady
                          ? Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                            )
                          : ShimmerHelper().buildBasicShimmer(
                              height: 30.0,
                            ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 14, left: 12, right: 12),
                      child: isReady
                          ? buildMainPriceRow()
                          : ShimmerHelper().buildBasicShimmer(
                              height: 30.0,
                            ),
                    ),
                    isReady
                        // category
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 12, right: 12),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 12, right: 12),
                            child: ShimmerHelper().buildBasicShimmer(
                              height: 40.0,
                            ),
                          ),
                    isReady
                        ? QuantityPriceRow(
                            singlePrice: product.currentPrice,
                            onAddToCart: (quantity) async {
                              if (await onPressAddToCart(quantity)) {
                                return true;
                              }
                              return false;
                            })
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14.0, vertical: 8.0),
                            child:
                                ShimmerHelper().buildBasicShimmer(height: 50.0),
                          ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: isReady
                    ? ProductRow(
                        title: "You may also Like",
                        maxItem: 6,
                        onSeeAll: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProductListScreen(
                              title: "You may also Like",
                              category: product.category,
                              flag: ProductListScreen.CATEGORY,
                              canSort: true,
                            );
                          }));
                        },
                        flag: ProductRow.CATEGORY,
                        category: product.category)
                    : ShimmerHelper().buildBasicShimmer(height: 160.0),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Row buildMainPriceRow() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8.0, bottom: 4),
          child: Text(
            "MRP",
            style: TextStyle(
                color: Color.fromARGB(255, 90, 97, 101),
                fontSize: 13.0,
                fontWeight: FontWeight.w400),
          ),
        ),
        product.originalPrice != product.currentPrice
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text("৳${product.originalPrice}",
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Color.fromRGBO(224, 224, 225, 1),
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                    )),
              )
            : Container(),
        Text(
          "৳${product.currentPrice}",
          style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 15.0,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
