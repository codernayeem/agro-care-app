import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostModel {
  // post_id, user_id, content, imageUrl, like_count, comment_count, created_at
  final String postId;
  final String userId;
  final String content;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final Timestamp createdAt;

  CommunityPostModel({
    required this.postId,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory CommunityPostModel.fromJson(
      Map<String, dynamic> data, String postId) {
    {
      return CommunityPostModel(
        postId: postId,
        userId: data['uid'] ?? '',
        content: data['content'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        likeCount: data['likes'] ?? 0,
        commentCount: data['comments'] ?? 0,
        createdAt: (data['created_at'] == null)
            ? Timestamp.now()
            : data['created_at'] as Timestamp,
      );
    }
  }
}
