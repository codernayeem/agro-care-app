import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/widgets/comments_modal.dart';
import 'package:agro_care_app/widgets/love_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../helpers/profile_image_provider.dart';
import '../model/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final CommunityPostModel post;
  final bool myPost;

  const PostCard({Key? key, required this.post, this.myPost = false})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String userName = '';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    FireStoreServices.publicUserData(widget.post.userId).get().then((value) {
      setState(() {
        userName = value['name'];
        userImage = value['photoUrl'];
      });
    });
  }

  void onCommentTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return CommentsModal(
          postId: widget.post.postId,
        );
      },
    );
  }

  void doDeletion() {
    FireStoreServices.communityRef()
        .collection('posts')
        .doc(widget.post.postId)
        .delete();
    // removes likes & comments
    FireStoreServices.communityRef()
        .collection('post_likes')
        .where('postId', isEqualTo: widget.post.postId)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    FireStoreServices.communityRef()
        .collection('comments')
        .where('postId', isEqualTo: widget.post.postId)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
  }

  void onDeletePress() {
    // show dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Post',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          content: const Text('This cant be undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                doDeletion();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red.shade100),
              ),
              child: const Text('Delete',
                  style: TextStyle(color: Color.fromARGB(255, 90, 16, 11))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                userImage.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: profileImageProvider(userImage),
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userName.isNotEmpty
                        ? Text(userName,
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                          ),
                    Text(
                      timeago.format(
                        widget.post.createdAt.toDate(),
                        locale: 'en_short',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.myPost)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey.shade500),
                    onPressed: onDeletePress,
                  ),
              ],
            ),
            const Divider(),
            Text(widget.post.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            widget.post.imageUrl.isNotEmpty
                ? Builder(
                    builder: (context) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 100,
                          maxHeight: 300,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.fitHeight,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                              height: 200,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            widget.post.imageUrl.isNotEmpty
                ? const SizedBox(height: 10)
                : const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LoveButton(postId: widget.post.postId),
                    Text("${widget.post.likeCount} Likes"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${widget.post.commentCount} Comments"),
                    InkWell(
                      onTap: () {
                        onCommentTap(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.comment_outlined,
                          color: Color.fromARGB(167, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
