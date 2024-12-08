import 'package:agro_care_app/screens/home/home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shimmer/shimmer.dart';

import 'package:timeago/timeago.dart' as timeago;

class AgriNewsPostPage extends StatelessWidget {
  final AgriPostModel post;
  const AgriNewsPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF09051C),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const SizedBox(height: 20),
              HtmlWidget(
                post.content,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
