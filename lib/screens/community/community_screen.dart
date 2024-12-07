import 'package:agro_care_app/model/post_model.dart';
import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/coummunity_top_input.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_services.dart';
import '../../widgets/post_card.dart';
import 'liked_post_screen.dart';
import 'my_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ref = FireStoreServices.communityRef();
  final AuthService auth = AuthService();
  late MyAuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<MyAuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onMyPostClick() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyPostsScreen(),
      ),
    );
  }

  void onLikedPostClick() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LikedPostsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAuthProvider>(builder: (context, auth, child) {
      return Scaffold(
        body: SafeArea(
          child: auth.isAuthenticated
              ? Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: FirestoreListView<Map<String, dynamic>>(
                        query: ref
                            .collection('posts')
                            .orderBy('created_at', descending: true),
                        emptyBuilder: (context) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.post_add,
                                    size: 100, color: Colors.grey),
                                SizedBox(height: 10),
                                Text('No posts yet',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                        itemBuilder: (context, snapshot) {
                          final post = CommunityPostModel.fromJson(
                              snapshot.data(), snapshot.id);
                          return PostCard(post: post);
                        },
                      ),
                    ),
                  ],
                )
              : unAuthenticated(),
        ),
      );
    });
  }

  Widget unAuthenticated() {
    return const Center(
      child: Text('Please sign in to view the community'),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          authProvider.userPhotoUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: CommunityTopBar(),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // equal spaced tonal buttons (icon + text) for (my post, loved post, refresh)
              topCardButton(Icons.post_add, 'My Post', onMyPostClick),
              topCardButton(Icons.favorite, 'Loved Post', onLikedPostClick),
              topCardButton(Icons.refresh, 'Refresh', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget topCardButton(IconData icon, String text, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
