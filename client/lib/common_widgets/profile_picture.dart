import 'package:flutter/material.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/styles/app_styles.dart';

class ProfilePicture extends StatelessWidget {
  final BoxShadow shadow;
  final double borderRadius;
  final String imageUrl;

  const ProfilePicture({
    required this.imageUrl,
    this.shadow = const BoxShadow(
      color: Color(0x40000000),
      blurRadius: 5,
      offset: Offset(0, 2),
    ),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [shadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ProxiedImage(imageUrl),
      ),
    );
  }
}
