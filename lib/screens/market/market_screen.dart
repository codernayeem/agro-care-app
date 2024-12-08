import 'package:agro_care_app/providers/cart_provider.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:flutter/material.dart';

import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../../widgets/carousel_slider.dart';
import '../../widgets/featured_categories_ui.dart';
import '../../widgets/product_row.dart';
import '../../widgets/shimmer_helper.dart';
import 'cart_screen.dart';
import 'product_list_screen.dart';
import 'search_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: buildAppBar(statusBarHeight, context),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const MyCarouselSlider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(
                  children: [
                    Text(
                      "Featured Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              const SizedBox(
                height: 150,
                child: HomeFeaturedCategories(),
              ),
              ProductRow(
                title: "Best Selling Products",
                flag: ProductRow.BEST_SELLING,
                maxItem: 6,
                onSeeAll: () {},
              ),
              ProductRow(
                title: "New Products",
                flag: ProductRow.NEW_PRODUCTS,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "New Products",
                      flag: ProductListScreen.NEW_PRODUCTS,
                      canSort: false,
                    );
                  }));
                },
              ),
              // top 6 categories
              ProductRow(
                title: "Seeds",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Seeds",
                      flag: ProductListScreen.CATEGORY,
                      category: 'seeds',
                      canSort: true,
                    );
                  }));
                },
                category: 'seeds',
              ),
              ProductRow(
                title: "Fertilizers",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Fertilizers",
                      flag: ProductListScreen.CATEGORY,
                      category: 'fertilizers',
                      canSort: true,
                    );
                  }));
                },
                category: 'fertilizers',
              ),
              ProductRow(
                title: "Pesticides",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Pesticides",
                      flag: ProductListScreen.CATEGORY,
                      category: 'pesticides',
                      canSort: true,
                    );
                  }));
                },
                category: 'pesticides',
              ),
              ProductRow(
                title: "Tools",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Tools",
                      flag: ProductListScreen.CATEGORY,
                      category: 'tools',
                      canSort: true,
                    );
                  }));
                },
                category: 'tools',
              ),
              ProductRow(
                title: "Indoor Plants",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Indoor Plants",
                      flag: ProductListScreen.CATEGORY,
                      category: 'indoor_plants',
                      canSort: true,
                    );
                  }));
                },
                category: 'indoor_plants',
              ),
              ProductRow(
                title: "Irrigation Supplies",
                flag: ProductRow.CATEGORY,
                maxItem: 6,
                onSeeAll: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProductListScreen(
                      title: "Irrigation Supplies",
                      flag: ProductListScreen.CATEGORY,
                      category: 'irrigation',
                      canSort: true,
                    );
                  }));
                },
                category: 'irrigation',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String text, IconData icon,
      void Function()? onTapFunction) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(36),
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(127, 50, 122, 246),
              Color.fromARGB(233, 50, 122, 246)
            ], // Attractive gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // Subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          splashColor: const Color.fromARGB(255, 52, 62, 203)
              .withOpacity(0.3), // Splash color
          onTap: onTapFunction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Padding(
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SearchScreen();
                  }));
                },
                splashColor: AppColors.primaryColor.withOpacity(0.3),
                child: homeSearchBox(context: context),
              ),
            ),
            const SizedBox(width: 4),
            // Cart
            IconButton(
              icon: badges.Badge(
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.all(5),
                ),
                badgeAnimation: const badges.BadgeAnimation.slide(
                  toAnimate: false,
                ),
                badgeContent: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Text(
                      "${cart.cartItemsCount}",
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    );
                  },
                ),
                child: Image.asset(
                  "assets/icons/cart.png",
                  color: Colors.black87,
                  height: 24,
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const CartPage();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget homeSearchBox({required BuildContext context}) {
    return Container(
      height: 36,
      decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
        color: Colors.white70,
        border: Border.all(color: AppColors.primaryColor, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Search Anything",
              style: TextStyle(fontSize: 13.0, color: Colors.grey[500]),
            ),
            Image.asset(
              'assets/icons/search.png',
              height: 16,
              color: Colors.grey[500],
            )
          ],
        ),
      ),
    );
  }
}
