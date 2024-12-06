import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/widgets/love_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../model/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final CommunityPostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        backgroundImage: CachedNetworkImageProvider(userImage),
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
                        // Add your onTap code here!
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
