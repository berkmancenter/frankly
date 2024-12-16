import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:universal_html/js.dart' as universal_js;

class JuntoImage extends StatelessWidget {
  final String? url;
  final AppAsset? asset;
  final double? height;
  final double? width;
  final Color loadingColor;
  final BorderRadius? borderRadius;
  final BoxFit? fit;

  const JuntoImage(
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

    if (processedUrl.startsWith('http://') && processedUrl.contains('cloudinary.com')) {
      processedUrl = processedUrl.replaceFirst('http://', 'https://');
    }

    final isNonCloudinaryHttp = processedUrl.startsWith('http://');

    final isCanvasKit = kIsWeb && universal_js.context['flutterCanvasKit'] != null;
    if (isCanvasKit || isNonCloudinaryHttp) {
      final domain = isDev
          ? 'us-central1-gen-hls-bkc-7627.cloudfunctions.net'
          : 'us-central1-asml-deliberations.cloudfunctions.net';
      processedUrl = 'https://$domain/imageProxy?url=${Uri.encodeQueryComponent(processedUrl)}';
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
    final localAsset = asset;

    // ignore: prefer_function_declarations_over_variables
    ImageFrameBuilder frameBuilder = (context, child, frame, loadedSynchronously) {
      if (!loadedSynchronously && frame == null) {
        return _buildLoadingWidget();
      }

      return child;
    };

    Widget errorBuilder(_, __, ___) => Container(
          height: height,
          width: width,
          color: AppColor.gray4,
          child: Icon(
            Icons.broken_image,
            size: 30,
          ),
        );

    final image = localAsset != null
        ? Image.asset(
            localAsset.path,
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
