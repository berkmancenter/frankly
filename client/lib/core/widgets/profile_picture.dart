import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/styles/styles.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    required this.imageUrl,
    this.boxShadow,
    this.borderRadius = 8.0,
  });

  final BoxShadow? boxShadow;
  final double borderRadius;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          boxShadow ??
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ProxiedImage(imageUrl),
      ),
    );
  }
}
