import 'package:agro_care_app/screens/home/news_page.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/weather_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/carousel_slider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../scan/camera_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final String phoneNumber = "+8801968199036";

  Future<void> _launchCall() async {
    if (!await launchUrl(Uri.parse("tel:$phoneNumber"))) {
      print("Could not launch $phoneNumber");
    }
  }

  Future<void> _launchWhatsApp() async {
    final encodedMessage = Uri.encodeComponent("Hello, I need help.");
    final url = "https://wa.me/$phoneNumber?text=$encodedMessage";

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const MyCarouselSlider(),
              Container(
                padding: const EdgeInsets.all(16),
                height: 200,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: buildCard(
                        context,
                        "Scan A Leaf",
                        'assets/icons/leaf.png',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: buildCard(
                        context,
                        "Call Us",
                        'assets/icons/call.webp',
                        _launchCall,
                      ),
                    ),
                    Expanded(
                      child: buildCard(
                        context,
                        "Knock us on WhatsApp",
                        'assets/icons/whatsapp.png',
                        _launchWhatsApp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const MyWeatherWidget()),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest News for you",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              FirestorePagination(
                limit: 10,
                viewType: ViewType.list,
                physics: const NeverScrollableScrollPhysics(),
                isLive: false,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                query: FirebaseFirestore.instance
                    .collection('agri_news')
                    .orderBy('datetime', descending: true),
                itemBuilder: (context, documentSnapshot, index) {
                  final data = AgriPostModel.formJson(
                      documentSnapshot.data() as Map<String, dynamic>);

                  return getItemView(context, data);
                },
                onEmpty: const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Maybe you should check your internet connection",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(197, 10, 28, 4),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String text, String image,
      void Function()? onTapFunction) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
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
              Color.fromARGB(200, 255, 255, 255),
              Color.fromARGB(213, 255, 255, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(36),
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          splashColor: AppColors.primaryColor.withOpacity(0.6),
          hoverColor: AppColors.primaryColor.withOpacity(0.1),
          onTap: onTapFunction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Image.asset(
                image,
                height: 48,
                width: 48,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 19, 51, 20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getItemView(BuildContext context, AgriPostModel post) {
    return InkWell(
      splashColor: const Color.fromARGB(53, 75, 114, 79),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgriNewsPostPage(post: post),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  topLeft: Radius.circular(4),
                ),
                color: Colors.black.withAlpha(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                tag: post.title,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Icon(Icons.error_outline_rounded),
                    );
                  },
                  placeholder: (context, url) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Container(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.category,
              style: const TextStyle(
                color: Color(0xFF4E4B66),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.12,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.12,
              ),
            ),
            Row(
              children: [
                Image.asset("assets/icon.png", width: 20),
                const SizedBox(width: 2),
                const Text(
                  'Agro Care',
                  style: TextStyle(
                    color: Color(0xFF4E4B66),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.12,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.access_time_sharp,
                  size: 15,
                ),
                const SizedBox(width: 5),
                if (post.datetime != null)
                  Text(
                    timeago.format(post.datetime!.toDate()),
                    style: const TextStyle(
                      color: Color(0xFF4E4B66),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class AgriPostModel {
  String title = "";
  String category = "";
  String imageUrl = "";
  String content = "";
  Timestamp? datetime;

  AgriPostModel.formJson(Map<String, dynamic> data) {
    title = data['title'];
    category = data['category'];
    imageUrl = data['imageUrl'];
    datetime = data['datetime'];
    content = data['content'];
  }
}
