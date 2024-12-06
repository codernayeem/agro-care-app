import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/firestore_services.dart';

class LoveButton extends StatefulWidget {
  final String postId;

  const LoveButton({Key? key, required this.postId}) : super(key: key);

  @override
  State<LoveButton> createState() => _LoveButtonState();
}

class _LoveButtonState extends State<LoveButton>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _controller;
  late String userId;

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Check if the user has liked the post
    FireStoreServices.communityRef()
        .collection("post_likes")
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: widget.postId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          isLiked = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    isLiked = !isLiked;
    if (isLiked) {
      _controller.forward(from: 0.2);
    } else {
      _controller.value = 0;
    }

    if (isLiked) {
      FireStoreServices.communityRef().collection("post_likes").add({
        'userId': userId,
        'postId': widget.postId,
        'createdAt': DateTime.now(),
      });
      FireStoreServices.communityRef()
          .collection("posts")
          .doc(widget.postId)
          .update({
        'likes': FieldValue.increment(1),
      });
    } else {
      FireStoreServices.communityRef()
          .collection("post_likes")
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: widget.postId)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
      FireStoreServices.communityRef()
          .collection("posts")
          .doc(widget.postId)
          .update({
        'likes': FieldValue.increment(-1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: LottieBuilder.asset(
        'assets/anim/heart.json',
        controller: _controller,
        width: 32,
        height: 32,
        onLoaded: (composition) {
          _controller.value = isLiked ? 1.0 : 0.0;
        },
      ),
    );
  }
}
