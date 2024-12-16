import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';

/// Section of the JuntoHomePage with a description of the community. It constrains the description
/// to a certain size and, if the text overflows, allows the user to expand the widget to see more
class JuntoHomeAboutSection extends StatefulWidget {
  final Junto junto;

  const JuntoHomeAboutSection({
    required this.junto,
    Key? key,
  }) : super(key: key);

  @override
  State<JuntoHomeAboutSection> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<JuntoHomeAboutSection> {
  static const maxDescriptionLength = 160;
  bool _isExpanded = false;

  @override
  void initState() {
    _isExpanded = JuntoProvider.read(context).isMeetingOfAmerica;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyle.body.copyWith(color: AppColor.gray1);
    final titleStyle = AppTextStyle.headline4.copyWith(color: AppColor.gray1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JuntoText('About Us', style: titleStyle),
        SizedBox(height: 10),
        SelectableLinkify(
          text: isNullOrEmpty(widget.junto.description)
              ? 'This section hasn\'t been filled in yet.'
              : (widget.junto.description!.length > maxDescriptionLength && !_isExpanded)
                  ? '${widget.junto.description!.substring(0, maxDescriptionLength)}...'
                  : widget.junto.description!,
          textAlign: TextAlign.left,
          style: textStyle,
          options: LinkifyOptions(looseUrl: true),
          onOpen: (link) => launch(link.url),
        ),
        SizedBox(height: 10),
        if (!_isExpanded &&
            widget.junto.description != null &&
            widget.junto.description!.length > maxDescriptionLength)
          JuntoInkWell(
            child: JuntoText(
              'Read More',
              style: textStyle,
            ),
            onTap: () => setState(() => _isExpanded = true),
          ),
        if (_isExpanded &&
            widget.junto.description != null &&
            widget.junto.description!.length > maxDescriptionLength)
          JuntoInkWell(
            child: JuntoText(
              'Less',
              style: textStyle,
            ),
            onTap: () => setState(() => _isExpanded = false),
          )
      ],
    );
  }
}
