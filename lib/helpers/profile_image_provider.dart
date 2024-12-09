import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

ImageProvider profileImageProvider(var url) {
  return ((url != null && url.isNotEmpty)
      ? CachedNetworkImageProvider(url as String) as ImageProvider
      : const AssetImage('assets/icons/profile_1.png'));
}
