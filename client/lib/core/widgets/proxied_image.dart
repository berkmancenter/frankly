import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:universal_html/js.dart' as universal_js;

class ProxiedImage extends StatelessWidget {
  final String? url;
  final AppAsset? asset;
  final double? height;
  final double? width;
  final Color loadingColor;
  final BorderRadius? borderRadius;
  final BoxFit? fit;

  const ProxiedImage(
    this.url, {
    this.asset,
    this.height,
    this.width,
    this.loadingColor = AppColor.gray5,
    this.borderRadius,
    this.fit,
  });

  String get processedUrl {
    var processedUrl = url ?? '';
    if (processedUrl.contains('picsum.photos')) {
      processedUrl = processedUrl.replaceAll('.webp', '');
    }

    if (processedUrl.startsWith('http://') &&
        processedUrl.contains('cloudinary.com')) {
      processedUrl = processedUrl.replaceFirst('http://', 'https://');
    }

    final isNonCloudinaryHttp = processedUrl.startsWith('http://');

    final isCanvasKit =
        kIsWeb && universal_js.context['flutterCanvasKit'] != null;
    if (isCanvasKit || isNonCloudinaryHttp) {
      processedUrl =
          '${Environment.functionsUrlPrefix}/imageProxy?url=${Uri.encodeQueryComponent(processedUrl)}';
    }

    return processedUrl;
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: height,
      width: width,
      color: loadingColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget frameBuilder(
      BuildContext context,
      Widget child,
      int? frame,
      bool loadedSynchronously,
    ) {
      if (!loadedSynchronously && frame == null) {
        return _buildLoadingWidget();
      }

      return child;
    }

    Widget errorBuilder(_, __, ___) => Container(
          height: height,
          width: width,
          color: AppColor.gray4,
          child: Icon(
            Icons.broken_image,
            size: 30,
          ),
        );

    final image = asset != null
        ? Image.asset(
            asset!.path,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            frameBuilder: frameBuilder,
            errorBuilder: errorBuilder,
          )
        : Image.network(
            processedUrl,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            frameBuilder: frameBuilder,
            errorBuilder: errorBuilder,
          );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
