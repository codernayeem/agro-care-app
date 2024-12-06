import 'dart:io';

import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/services/community_service.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';

import '../../helpers/snackbar_show.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late MyAuthProvider authProvider;

  File? _image;
  late TextEditingController _contentController;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void onClickPost() async {
    if (_contentController.text.trim().isEmpty) {
      return;
    }

    var content = _contentController.text.trim();

    var res = await CommunityService.createPost(
        authProvider.userId!, content, _image);

    if (res.success) {
      showSnackBar(context, "Post created successfully");
      Navigator.pop(context);
    } else {
      showSnackBar(context, res.message);
    }
  }

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    authProvider = Provider.of<MyAuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post',
            style: TextStyle(color: Colors.black87, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: onClickPost,
            child: const Text(
              'Post',
              style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Card(
          surfaceTintColor: Colors.white,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Public post",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  maxLines: null,
                  minLines: 6,
                  controller: _contentController,
                  decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.darkGreen),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.all(12)),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_image == null)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton.icon(
                      onPressed: _selectImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                    ),
                  ])
                else
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            height: 200,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton.tonal(
                            onPressed: _selectImage,
                            child: const Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 4),
                                Text('Change'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              color: Colors.red.shade300,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.red.shade100),
                              ),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade900,
                              )),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
