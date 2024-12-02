import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../services/auth_services.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

  final ref = FireStoreServices.communityRef();
  final AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isHeaderVisible) setState(() => _isHeaderVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isHeaderVisible) setState(() => _isHeaderVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isHeaderVisible ? 130.0 : 0.0,
            child: _buildHeader(),
          ),
          Expanded(
            child: FirestoreListView<Map<String, dynamic>>(
              query: ref
                  .collection('posts')
                  .orderBy('timestamp', descending: true),
              controller: _scrollController,
              emptyBuilder: (context) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.post_add, size: 100, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No posts yet',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
              itemBuilder: (context, snapshot) {
                final post = snapshot.data();
                return _buildPostCard(post);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<MyAuthProvider>(builder: (context, auth, child) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: auth.userPhotoUrl != ""
                      ? NetworkImage(auth.userPhotoUrl)
                      : null,
                  radius: 30,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // Replace with the logged-in user's name
                      auth.userName.isEmpty ? 'Anonymous' : auth.userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                FilledButton.tonal(
                    onPressed: () {}, child: const Text("My Posts")),
                const SizedBox(width: 4),
                FilledButton.tonal(
                    onPressed: () {}, child: const Text("Saved Posts")),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    // Replace with user's image fetched from Firestore
                    post['user_image'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['user_name'] ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post['timestamp'] != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                                post['timestamp'].seconds * 1000)
                            .toString()
                        : 'Just now'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post['text'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            post['image_list'] != null &&
                    (post['image_list'] as List).isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (post['image_list'] as List).length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(post['image_list'][index]),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Likes: ${post['like_count'] ?? 0}"),
                Text("Comments: ${post['comment_count'] ?? 0}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
