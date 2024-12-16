import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';
import 'package:provider/provider.dart';

class HostingOption extends StatefulWidget {
  final Function(DiscussionType?) selectedDiscussionType;
  final bool isHostlessEnabled;
  final DiscussionType initialHostingOption;
  final bool isWhiteBackground;

  const HostingOption({
    Key? key,
    required this.selectedDiscussionType,
    required this.isHostlessEnabled,
    required this.initialHostingOption,
    this.isWhiteBackground = true,
  }) : super(key: key);

  @override
  State<HostingOption> createState() => _HostingOptionState();
}

class _HostingOptionState extends State<HostingOption> {
  late DiscussionType _hostingOption = widget.initialHostingOption;

  @override
  Widget build(BuildContext context) {
    return JuntoStreamGetterBuilder<PlanCapabilityList>(
      entryFrom: '_HostingOptionState._buildContent',
      streamGetter: () => cloudFunctionsService
          .getJuntoCapabilities(
            GetJuntoCapabilitiesRequest(juntoId: Provider.of<JuntoProvider>(context).juntoId),
          )
          .asStream(),
      textStyle: AppTextStyle.body.copyWith(
        color: widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
      ),
      height: 100,
      builder: (context, caps) {
        List<_HostingOptionType> hostingTypes = [
          _HostingOptionType(
            title: 'Hosted',
            isGated: false,
            discussionType: DiscussionType.hosted,
          ),
          if (widget.isHostlessEnabled)
            _HostingOptionType(
              title: 'Hostless',
              isGated: !(caps?.hasLivestreams ?? false),
              discussionType: DiscussionType.hostless,
            ),
          _HostingOptionType(
            title: 'Livestream',
            isGated: !(caps?.hasLivestreams ?? false),
            discussionType: DiscussionType.livestream,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final type in hostingTypes)
                  if (!type.isGated)
                    _HostingRadioOption(
                      isWhiteBackground: widget.isWhiteBackground,
                      onSelected: () {
                        widget.selectedDiscussionType(type.discussionType);
                        setState(() => _hostingOption = type.discussionType);
                      },
                      isSelected: type.discussionType == _hostingOption,
                      isGated: type.isGated,
                      title: type.title,
                    ),
              ].intersperse(SizedBox(height: 14)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _HostingOptionType {
  final String title;
  final bool isGated;
  final DiscussionType discussionType;

  _HostingOptionType({
    required this.title,
    required this.isGated,
    required this.discussionType,
  });
}

class _HostingRadioOption extends StatefulWidget {
  final bool isGated;
  final bool isSelected;
  final void Function() onSelected;
  final String title;
  final bool isWhiteBackground;

  const _HostingRadioOption({
    Key? key,
    this.isGated = true,
    required this.title,
    required this.isSelected,
    required this.onSelected,
    this.isWhiteBackground = false,
  }) : super(key: key);

  @override
  State<_HostingRadioOption> createState() => _HostingRadioOptionState();
}

class _HostingRadioOptionState extends State<_HostingRadioOption> {
  Color get color {
    if (widget.isWhiteBackground) {
      if (!widget.isGated) {
        return AppColor.darkBlue;
      } else {
        return AppColor.darkBlue.withOpacity(.5);
      }
    } else {
      if (!widget.isGated) {
        return AppColor.white;
      } else {
        return AppColor.white.withOpacity(.5);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color)),
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: widget.isSelected
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  )
                : null,
          ),
          SizedBox(width: 10),
          Flexible(
            child: JuntoText(widget.title, style: AppTextStyle.body.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
