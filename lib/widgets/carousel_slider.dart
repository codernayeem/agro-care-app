import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/shimmer_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyCarouselSlider extends StatefulWidget {
  final bool isMarket;
  const MyCarouselSlider({Key? key, this.isMarket = false}) : super(key: key);

  @override
  State<MyCarouselSlider> createState() => _MyCarouselSliderState();
}

class _MyCarouselSliderState extends State<MyCarouselSlider> {
  int _currentIndex = 0;
  bool isReady = false;

  List<String> carouselImageList = [];
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
  }

  Future<void> fetchCarouselImages() async {
    setState(() {
      isReady = false;
    });

    var ref = FireStoreServices.db
        .collection(widget.isMarket ? 'banners2' : 'banners');
    var querySnapshot = await ref.get();
    carouselImageList = querySnapshot.docs
        .map((doc) => doc.data()['photoUrl'] as String)
        .toList();

    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 0,
          bottom: 20,
        ),
        child: ShimmerHelper().buildBasicShimmer(
          height: 180,
        ),
      );
    }

    if (carouselImageList.isNotEmpty) {
      return Column(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              aspectRatio: 338 / 140 - 0.1,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: carouselImageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, top: 8, bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(i),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 4,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: carouselImageList.map((url) {
              int index = carouselImageList.indexOf(url);
              return Container(
                width: 7.0,
                height: 7.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? AppColors.primaryColor
                      : const Color.fromRGBO(112, 112, 112, .3),
                ),
              );
            }).toList(),
          )
        ],
      );
    } else {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No carousel image found',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }
  }
}
