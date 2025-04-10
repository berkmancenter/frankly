import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class MeetingRating extends StatefulWidget {
  Future<void> showInDialog({
    required EventProvider eventProvider,
    required LiveMeetingProvider liveMeetingProvider,
    required CommunityProvider communityProvider,
  }) {
    return showCustomDialog<void>(
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
                value: eventProvider,
                child: ChangeNotifierProvider.value(
                  value: liveMeetingProvider,
                  child: ChangeNotifierProvider.value(
                    value: communityProvider,
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
                      sendingIndicatorAlign:
                          ActionButtonSendingIndicatorAlign.none,
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
    final rating = await firestoreLiveMeetingService
        .getRating(EventProvider.read(context).event);
    return _currentRating = rating?.rating;
  }

  Widget _buildRatingSection() {
    final currentRating = _currentRating;

    return FutureBuilder<double?>(
      future: _initialRating ??= _getInitialRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CustomLoadingIndicator());
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
                currentRating != null && value < currentRating
                    ? Icons.star
                    : Icons.star_outline,
                color: AppColor.brightGreen,
              );
            },
            unratedColor: AppColor.white.withOpacity(0.5),
            onRatingUpdate: (rating) => alertOnError(context, () async {
              setState(() => _currentRating = rating);
              final event = context.read<EventProvider>().event;

              await firestoreLiveMeetingService.updateRating(
                event,
                rating,
              );
              analytics.logEvent(
                AnalyticsRateEventEvent(
                  communityId: event.communityId,
                  eventId: event.id,
                  rating: rating,
                ),
              );
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
      child: CustomInkWell(
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
    final ratingSurveyUrl =
        CommunityProvider.read(context).community.ratingSurveyUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildExitButton(),
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 15),
            child: HeightConstrainedText(
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
                  child: HeightConstrainedText(
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
                  child: HeightConstrainedText(
                    'Provide feedback for ${CommunityProvider.read(context).community.name}',
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
                      child: CustomInkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => launch(ratingSurveyUrl),
                        child: HeightConstrainedText(
                          'Please provide additional feedback for '
                          '${CommunityProvider.read(context).community.name} here',
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
