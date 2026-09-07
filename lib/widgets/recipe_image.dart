import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  bool get isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (!isNetworkImage) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return Image.network(
      imagePath,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 42,
        color: Colors.grey,
      ),
    );
  }
}
