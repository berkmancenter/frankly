import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';

/// Section of the CommunityHomePage with a description of the community. It constrains the description
/// to a certain size and, if the text overflows, allows the user to expand the widget to see more
class CommunityHomeAboutSection extends StatefulWidget {
  final Community community;

  const CommunityHomeAboutSection({
    required this.community,
    Key? key,
  }) : super(key: key);

  @override
  State<CommunityHomeAboutSection> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<CommunityHomeAboutSection> {
  static const maxDescriptionLength = 160;
  bool _isExpanded = false;

  @override
  void initState() {
    _isExpanded = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyle.body.copyWith(color: AppColor.gray1);
    final titleStyle = AppTextStyle.headline4.copyWith(color: AppColor.gray1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeightConstrainedText('About Us', style: titleStyle),
        SizedBox(height: 10),
        SelectableLinkify(
          text: isNullOrEmpty(widget.community.description)
              ? 'This section hasn\'t been filled in yet.'
              : (widget.community.description!.length > maxDescriptionLength &&
                      !_isExpanded)
                  ? '${widget.community.description!.substring(0, maxDescriptionLength)}...'
                  : widget.community.description!,
          textAlign: TextAlign.left,
          style: textStyle,
          options: LinkifyOptions(looseUrl: true),
          onOpen: (link) => launch(link.url),
        ),
        SizedBox(height: 10),
        if (!_isExpanded &&
            widget.community.description != null &&
            widget.community.description!.length > maxDescriptionLength)
          CustomInkWell(
            child: HeightConstrainedText(
              'Read More',
              style: textStyle,
            ),
            onTap: () => setState(() => _isExpanded = true),
          ),
        if (_isExpanded &&
            widget.community.description != null &&
            widget.community.description!.length > maxDescriptionLength)
          CustomInkWell(
            child: HeightConstrainedText(
              'Less',
              style: textStyle,
            ),
            onTap: () => setState(() => _isExpanded = false),
          ),
      ],
    );
  }
}
