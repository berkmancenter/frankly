import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/extensions.dart';

/// Displays emotions (Emoji) section with the counter (total count of all emotions).
///
/// If there are no emotions available - shows `no emojis` image placeholder.
/// If there are emotions available - shows all unique emotions and overall emotions count.
class EmotionSection extends StatelessWidget {
  final List<Emotion> emotions;
  final Emotion? currentlySelectedEmotion;
  final void Function(EmotionType) onEmotionTypeSelect;

  const EmotionSection({
    Key? key,
    required this.emotions,
    required this.currentlySelectedEmotion,
    required this.onEmotionTypeSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popupButtonKey = GlobalKey<PopupMenuButtonState<EmotionType>>();
    const kIconSize = 20.0;
    // When switching between `no emotions` to `some emotions` views, we need to make sure
    // that the height is exactly the same. Otherwise there will be slight UI glitch.
    // 16 compensation comes from vertical padding (8+8).
    const kEmojiContainerHeightCompensation = 16.0;
    const maxHeight = kIconSize + kEmojiContainerHeightCompensation;
    final emotionCount = emotions.length;

    if (emotionCount == 0) {
      return ConstrainedBox(
        // Make sure to assign height, otherwise when selecting emotion, UI might slightly shift.
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _buildEmotionButton(context, popupButtonKey),
      );
    }

    final uniqueEmotions = emotions.map((e) => e.emotionType).toSet().toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => popupButtonKey.currentState?.showButtonMenu(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Make sure to lock in the width, so no potential overflow would happen
                // on small devices. Once this width is reached, list becomes scrollable and all
                // emotions can be visible.
                maxWidth: 100,
                maxHeight: maxHeight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: uniqueEmotions.length,
                    itemBuilder: (context, index) {
                      final uniqueEmotion = uniqueEmotions[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 2,
                        ),
                        child: ProxiedImage(
                          null,
                          asset: uniqueEmotion.imageAssetPath,
                          width: kIconSize,
                          height: kIconSize,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                  _buildEmotionButton(context, popupButtonKey),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(
          '$emotionCount',
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
        ),
      ],
    );
  }

  Widget _buildEmotionButton(
    BuildContext context,
    GlobalKey<PopupMenuButtonState<EmotionType>> popupButtonKey,
  ) {
    const kIconSize = 20.0;
    final borderRadius = BorderRadius.circular(10);

    return Theme(
      // Very ugly workaround. Currently there is no option to remove `tooltip` therefore
      // we simply `hide` it via transparency.
      // https://github.com/flutter/flutter/issues/60418
      data: Theme.of(context).copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
      child: PopupMenuButton<EmotionType>(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
        key: popupButtonKey,
        // Showing above the initial emotion.
        offset: Offset(0, -60),
        elevation: 2,
        // Make sure to pass nothing. If `null` is passed, it will show `Show Menu`.
        tooltip: '',
        icon: ProxiedImage(
          null,
          asset: AppAsset.kSmileyWithPlusPng,
          width: kIconSize,
          height: kIconSize,
        ),
        iconSize: kIconSize,
        itemBuilder: (context) {
          return [
            PopupMenuWidget(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: EmotionType.values.map((emotionType) {
                    return InkWell(
                      borderRadius: borderRadius,
                      onTap: () async {
                        await guardSignedIn(() async {
                          onEmotionTypeSelect(emotionType);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: emotionType ==
                                  currentlySelectedEmotion?.emotionType
                              ? AppColor.gray6
                              : Colors.transparent,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ProxiedImage(
                            null,
                            asset: emotionType.imageAssetPath,
                            width: kIconSize,
                            height: kIconSize,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ];
        },
      ),
    );
  }
}

/// Very hacky way to make horizontal [PopupMenuButton]. Taken from example
/// https://stackoverflow.com/a/43862514/4722635
class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  final Widget child;

  const PopupMenuWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();

  @override
  bool represents(T? value) {
    throw UnimplementedError();
  }

  @override
  double get height => throw UnimplementedError();
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
