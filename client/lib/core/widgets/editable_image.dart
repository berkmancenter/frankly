import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/app_asset.dart';

class EditableImage extends StatefulWidget {
  final Widget child;
  final Function(String)? onImageSelect;
  final String initialUrl;
  final Widget? icon;
  final bool? allowEdit;
  final BorderRadius? borderRadius;

  const EditableImage({
    required this.child,
    required this.initialUrl,
    this.onImageSelect,
    this.allowEdit,
    this.icon,
    this.borderRadius,
  });

  @override
  _EditableImageState createState() => _EditableImageState();
}

class _EditableImageState extends State<EditableImage> {
  Widget _buildEditPhotoOverlay({double? aspectRatio}) {
    final onImageSelect = widget.onImageSelect;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: CustomInkWell(
          borderRadius: widget.borderRadius,
          onTap: () => alertOnError(context, () async {
            String? url = await GetIt.instance<MediaHelperService>()
                .pickImageViaCloudinary();
            url = url?.trim();

            if (onImageSelect != null &&
                url != null &&
                url.isNotEmpty &&
                url != widget.initialUrl) {
              await onImageSelect(url);
            }
          }),
          child: Align(
            alignment: Alignment.center,
            child: Semantics(
              label: 'Edit Image',
              child: widget.icon ??
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(AppAsset.kAddPhotoSvg.path),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (widget.allowEdit == true)
            _buildEditPhotoOverlay(
              aspectRatio: constraints.biggest.aspectRatio,
            ),
        ],
      ),
    );
  }
}
