import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class MeetingRating extends StatefulWidget {
  Future<void> showInDialog({
    required DiscussionProvider discussionProvider,
    required LiveMeetingProvider liveMeetingProvider,
    required JuntoProvider juntoProvider,
  }) {
    return showJuntoDialog<void>(
      builder: (innerContext) => Dialog(
        backgroundColor: AppColor.darkBlue,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChangeNotifierProvider.value(
                value: discussionProvider,
                child: ChangeNotifierProvider.value(
                  value: liveMeetingProvider,
                  child: ChangeNotifierProvider.value(
                    value: juntoProvider,
                    child: this,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      onPressed: () => Navigator.of(innerContext).pop(),
                      text: 'No thanks',
                      color: Colors.transparent,
                      textColor: AppColor.white,
                    ),
                    ActionButton(
                      onPressed: () => Navigator.of(innerContext).pop(),
                      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                      text: 'NEXT',
                      color: AppColor.brightGreen,
                      textColor: AppColor.darkBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  _MeetingRatingState createState() => _MeetingRatingState();
}

class _MeetingRatingState extends State<MeetingRating> {
  double? _currentRating;
  Future<double?>? _initialRating;

  Future<double?> _getInitialRating() async {
    final rating =
        await firestoreLiveMeetingService.getRating(DiscussionProvider.read(context).discussion);
    return _currentRating = rating?.rating;
  }

  Widget _buildRatingSection() {
    final currentRating = _currentRating;

    return FutureBuilder<double?>(
      future: _initialRating ??= _getInitialRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: JuntoLoadingIndicator());
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: RatingBar.builder(
            initialRating: snapshot.data ?? 0.0,
            minRating: 1,
            direction: Axis.horizontal,
            itemCount: 5,
            itemSize: responsiveLayoutService.isMobile(context) ? 46 : 58.0,
            itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
            tapOnlyMode: true,
            itemBuilder: (_, value) {
              return Icon(
                currentRating != null && value < currentRating ? Icons.star : Icons.star_outline,
                color: AppColor.brightGreen,
              );
            },
            unratedColor: AppColor.white.withOpacity(0.5),
            onRatingUpdate: (rating) => alertOnError(context, () async {
              setState(() => _currentRating = rating);

              await firestoreLiveMeetingService.updateRating(
                  context.read<DiscussionProvider>().discussion, rating);
            }),
          ),
        );
      },
    );
  }

  Widget _buildExitButton() {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: JuntoInkWell(
        onTap: () => Navigator.of(context).pop(),
        boxShape: BoxShape.circle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.close,
            color: AppColor.white,
            size: 35,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratingSurveyUrl = JuntoProvider.read(context).junto.ratingSurveyUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildExitButton(),
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 15),
            child: JuntoText(
              'YOU LEFT THE EVENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.transparent,
                  child: JuntoText(
                    'How was the event?',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.headline1.copyWith(
                      color: AppColor.white,
                      // Trying to keep from wrapping at the default dialog size due to:
                      // https://github.com/flutter/flutter/issues/89586
                      fontSize: 36,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  color: Colors.transparent,
                  child: JuntoText(
                    'Provide feedback for ${JuntoProvider.read(context).junto.name}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColor.white,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildRatingSection(),
                if (ratingSurveyUrl != null && ratingSurveyUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: JuntoInkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => launch(ratingSurveyUrl),
                        child: JuntoText(
                          'Please provide additional feedback for '
                          '${JuntoProvider.read(context).junto.name} here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            fontSize: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
