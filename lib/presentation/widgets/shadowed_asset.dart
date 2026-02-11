import 'package:flutter/material.dart';

/// Asset görseli gölge katmanı ile çizer (main/game ekranlarındaki ikon stili).
class ShadowedAsset extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  const ShadowedAsset({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 2,
            top: 4,
            child: Image.asset(
              imagePath,
              width: width,
              height: height,
              fit: fit,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
          ),
        ],
      ),
    );
  }
}
