import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/post_model.dart';
import '../../services/firestore_services.dart';
import '../../widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
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
        title: const Text('My Posts',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: FirestoreListView<Map<String, dynamic>>(
        query: ref
            .collection('posts')
            .where('uid', isEqualTo: userId)
            .orderBy('created_at', descending: true),
        emptyBuilder: (context) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 100, color: Colors.grey),
                SizedBox(height: 10),
                Text('No posts yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
        itemBuilder: (context, snapshot) {
          if (!snapshot.exists) {
            return Container();
          }

          final post =
              CommunityPostModel.fromJson(snapshot.data(), snapshot.id);
          return PostCard(post: post, myPost: true);
        },
      ),
    );
  }
}
