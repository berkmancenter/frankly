import 'package:flutter/material.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';

class LeaveSuggestionsDialogPreview extends StatelessWidget {
  final Junto? junto;
  final void Function()? onFollowTap;

  const LeaveSuggestionsDialogPreview({
    Key? key,
    this.junto,
    this.onFollowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: Container(color: AppColor.black)),
                Expanded(child: Container(color: Colors.blue)),
                Expanded(child: Container(color: Colors.red)),
                Expanded(child: Container(color: Colors.lightGreen)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(child: LeaveSuggestionsDialog(junto: junto, onFollowTap: onFollowTap)),
                Expanded(child: Container(color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveSuggestionsDialog extends StatefulWidget {
  final Junto? junto;
  final void Function()? onFollowTap;

  const LeaveSuggestionsDialog({
    Key? key,
    this.junto,
    this.onFollowTap,
  }) : super(key: key);

  @override
  State<LeaveSuggestionsDialog> createState() => _LeaveSuggestionsDialogState();
}

class _LeaveSuggestionsDialogState extends State<LeaveSuggestionsDialog> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = responsiveLayoutService.isMobile(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: AppColor.white),
        child: Stack(
          children: [
            if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColor.darkBlue, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildThatIsItSection() {
    final bool canFollowJunto = widget.junto != null && widget.onFollowTap != null;
    String content;

    if (canFollowJunto) {
      content =
          'That’s the end of your agenda. You can hang out and finish up for as long as you’d like. Follow ${widget.junto?.name} for more great events.';
    } else {
      content =
          'That’s the end of your agenda. You can hang out and finish up for as long as you’d like.';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        JuntoText(
          "That's it!",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: responsiveLayoutService.getDynamicSize(context, 24, scale: 3 / 4),
            color: AppColor.darkBlue,
          ),
        ),
        SizedBox(height: 20),
        Flexible(
          child: JuntoText(
            content,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: responsiveLayoutService.getDynamicSize(context, 18, scale: 3 / 4),
              color: AppColor.darkBlue,
            ),
          ),
        ),
        SizedBox(height: 16),
        if (canFollowJunto)
          ActionButton(
            type: ActionButtonType.outline,
            text: 'Follow ${widget.junto?.name}',
            textColor: AppColor.darkBlue,
            borderSide: BorderSide(color: AppColor.darkBlue),
            onPressed: widget.onFollowTap,
          ),
      ],
    );
  }

  Widget _buildOpenSuggestionsButton() {
    return ActionButton(
      text: 'Open Suggestions',
      textColor: AppColor.brightGreen,
      color: AppColor.darkBlue,
      onPressed: () {},
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: _buildThatIsItSection(),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(18),
            color: AppColor.gray6,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(
                      child: JuntoText(
                        'some text',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColor.darkBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: JuntoText(
                        'some other text text text text text text',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppColor.darkBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                _buildOpenSuggestionsButton(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDesktopLayout() {
    // Extremely precise `flex` to make sure nothing is overflown.
    return Row(
      children: [
        Expanded(
          flex: 9,
          child: Container(
            padding: EdgeInsets.all(36),
            child: _buildThatIsItSection(),
          ),
        ),
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(36.0),
            color: AppColor.gray6,
            child: Column(
              children: [
                Spacer(),
                JuntoText(
                  'some text text',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColor.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                JuntoText(
                  'some other text text text text text text',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColor.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                _buildOpenSuggestionsButton(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
