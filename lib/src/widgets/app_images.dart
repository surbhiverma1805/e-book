import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width, height, radius;
  final Widget? errorWidget;

  const AppCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        // cacheKey: imageUrl.trim(),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            ImageProgressIndicator(
          progress: downloadProgress.progress,
        ),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.error),
      ),
    );
  }
}

class AppLocalFileImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width, height, radius;
  final Widget? errorWidget;

  const AppLocalFileImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
      ),
      child: Image.file(
        File(imageUrl),
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}

class ImageProgressIndicator extends StatelessWidget {
  const ImageProgressIndicator({Key? key, this.progress}) : super(key: key);

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            value: progress != null ? progress! / 100 : null,
            color: darkBlueColor),
      ),
    );
  }
}
