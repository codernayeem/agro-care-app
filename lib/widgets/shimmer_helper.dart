import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyTheme {
  static Color shimmer_base = Colors.grey.shade300;
  static Color shimmer_highlighted = Colors.white;
}

class BoxDecorations {
  static BoxDecoration buildBoxDecoration_1({double radius = 6}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: const Color.fromARGB(255, 11, 10, 10),
    );
  }
}

class ShimmerHelper {
  Widget buildBasicShimmer(
      {double height = double.infinity,
      double width = double.infinity,
      double radius = 6}) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecorations.buildBoxDecoration_1(radius: radius),
      ),
    );
  }

  Widget buildBasicShimmerCustomRadius(
      {double height = double.infinity,
      double? width = double.infinity,
      BorderRadius radius = BorderRadius.zero,
      Color color = Colors.grey}) {
    return Shimmer.fromColors(
      baseColor: color,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: height,
        width: width,
        decoration:
            BoxDecoration(borderRadius: radius, color: MyTheme.shimmer_base),
      ),
    );
  }

  buildListShimmer({item_count = 10, item_height = 100.0}) {
    return ListView.builder(
      itemCount: item_count,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: ShimmerHelper().buildBasicShimmer(height: item_height),
        );
      },
    );
  }

  buildProductGridShimmer({scontroller, item_count = 10}) {
    return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        controller: scontroller,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(item_count, (index) {
          return Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          );
        }));
  }

  buildCategoryCardShimmer({is_base_category}) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
        crossAxisCount: 3,
      ),
      itemCount: 18,
      padding: EdgeInsets.only(
          left: 18, right: 18, bottom: is_base_category ? 30 : 0),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }

  buildSquareGridShimmer({scontroller, item_count = 10}) {
    return GridView.builder(
      itemCount: item_count,
      controller: scontroller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1),
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          ),
        );
      },
    );
  }

  buildHorizontalGridShimmerWithAxisCount(
      {item_count = 10,
      int crossAxisCount = 2,
      crossAxisSpacing = 10.0,
      mainAxisSpacing = 10.0,
      mainAxisExtent = 100.0,
      controller}) {
    return GridView.builder(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: item_count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: 10,
            mainAxisExtent: mainAxisExtent),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          );
        });
  }

  buildSeparatedHorizontalListShimmer(
      {scontroller, item_count = 10, double height = 100.0}) {
    return GridView.builder(
      itemCount: item_count,
      controller: scontroller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 6,
          mainAxisExtent: height),
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(.08),
                //     blurRadius: 20,
                //     spreadRadius: 0.0,
                //     offset: Offset(0.0, 10.0), // shadow direction: bottom right
                //   )
                // ],
              ),
            ),
          ),
        );
      },
    );
  }

  buildProductRowShimmer({itemCount = 6, double height = 150}) {
    return GridView.builder(
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemCount,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          mainAxisExtent: height),
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
