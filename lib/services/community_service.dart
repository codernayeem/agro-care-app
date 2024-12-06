import 'dart:io';

import 'package:agro_care_app/model/status_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firestore_services.dart';

class CommunityService {
  static Future<Status> createPost(
      String uid, String content, File? image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      var imageUrl = '';

      if (image != null) {
        var ref = storage
            .ref()
            .child('posts')
            .child(uid)
            .child("$uid${DateTime.now()}.jpg");
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      }

      await FireStoreServices.communityRef().collection('posts').add({
        'uid': uid,
        'content': content,
        'imageUrl': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      });
      return Status.success();
    } catch (e) {
      print("Error creating post: $e");
      return Status.fail(message: e.toString());
    }
  }
}
