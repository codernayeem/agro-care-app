import 'dart:collection';

import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timeago/timeago.dart' as timeago;

class CommentsModal extends StatefulWidget {
  final String postId;
  const CommentsModal({super.key, required this.postId});

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();

  final ref = FireStoreServices.communityRef().collection('comments');
  late DocumentReference<Map<String, dynamic>> postRef;
  late String userId;

  @override
  void initState() {
    super.initState();
    postRef =
        FireStoreServices.communityRef().collection('posts').doc(widget.postId);
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      ref.add({
        'text': _commentController.text,
        'postId': widget.postId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      postRef.update({
        'comments': FieldValue.increment(1),
      });

      _commentController.clear();
    }
  }

  void onCommentTap() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add a comment',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          content: TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
                hintText: 'Enter your comment', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                _addComment();
                Navigator.pop(context);
              },
              child: const Text('Comment'),
            ),
          ],
        );
      },
    );
  }

  HashMap<String, String> userCache = HashMap<String, String>();
  HashMap<String, String> userImageCache = HashMap<String, String>();

  Future<HashMap<String, String>> _getUserData(String userId) async {
    if (userCache.containsKey(userId)) {
      return HashMap<String, String>.from({
        'name': userCache[userId]!,
        'photoUrl': userImageCache[userId]!,
      });
    }
    var data = await FireStoreServices.publicUserData(userId).get();
    userCache[userId] = data['name'];
    userImageCache[userId] = data['photoUrl'];
    return HashMap<String, String>.from({
      'name': userCache[userId]!,
      'photoUrl': userImageCache[userId]!,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Comments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: onCommentTap,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref
            .where('postId', isEqualTo: widget.postId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No comments yet'));
          }
          final comments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return buildComment(comment);
            },
          );
        },
      ),
    );
  }

  Widget buildComment(DocumentSnapshot comment) {
    return FutureBuilder<HashMap<String, String>>(
      future: _getUserData(comment['userId']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        width: 150.0,
                        height: 10.0,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userData['photoUrl']!),
                radius: 20.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      comment['text'],
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      comment['timestamp'] != null
                          ? timeago.format(comment['timestamp'].toDate())
                          : 'Just now',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
