import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../model/post_model.dart';
import '../services/firestore_services.dart';
import '../widgets/post_card.dart';

class LikedPostsScreen extends StatefulWidget {
  const LikedPostsScreen({super.key});

  @override
  State<LikedPostsScreen> createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  late String userId;

  final ref = FireStoreServices.communityRef();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: FirestoreListView<Map<String, dynamic>>(
        query: ref.collection('post_likes').where('userId', isEqualTo: userId),
        emptyBuilder: (context) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 100, color: Colors.grey),
                SizedBox(height: 10),
                Text('No liked posts yet',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
        itemBuilder: (context, snapshot) {
          if (!snapshot.exists) {
            return Container();
          }

          final postId = snapshot.data()['postId'];

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: ref.collection('posts').doc(postId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  !snapshot.data!.exists ||
                  snapshot.data!.data() == null) {
                return const SizedBox();
              }

              final post =
                  CommunityPostModel.fromJson(snapshot.data!.data()!, postId);
              return PostCard(post: post, myPost: post.userId == userId);
            },
          );
        },
      ),
    );
  }
}
