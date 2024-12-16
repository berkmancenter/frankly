import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/freemium_dialog_flow.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_icon_or_logo.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/user_info_builder.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/widgets_preview/widgets_preview.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/public_user_info.dart';

import 'creation_dialog/theme_creation_utility.dart';

/// This is the top section of the home page that displays a carousel of images which link to the community home pages
class MyCommunitiesSection extends StatefulWidget {
  const MyCommunitiesSection({Key? key}) : super(key: key);

  @override
  _MyCommunitiesSectionState createState() => _MyCommunitiesSectionState();
}

class _MyCommunitiesSectionState extends State<MyCommunitiesSection> {
  static const double _communityCardSize = 295;

  void _createCommunityPressed() {
    guardSignedIn(() => FreemiumDialogFlow().show());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitle(),
        SizedBox(height: 20),
        _buildCommunitiesCarousel(),
      ],
    );
  }

  Widget _buildTitle() => Padding(
        padding:
            EdgeInsets.symmetric(horizontal: responsiveLayoutService.isMobile(context) ? 20 : 0),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: responsiveLayoutService.isMobile(context) ? 550 : 1100),
          child: UserInfoBuilder(
            userId: userService.currentUserId,
            builder:
                (BuildContext context, bool isLoading, AsyncSnapshot<PublicUserInfo?> snapshot) {
              final userInfo = snapshot.data;
              if (isLoading) {
                return Row(children: const [CircularProgressIndicator()]);
              }
              final owner = userInfo?.isOwner ?? false;
              return Row(
                children: [
                  GestureDetector(
                    onTap: isDev
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WidgetsPreview()),
                            )
                        : null,
                    child: JuntoText(
                      'My Communities',
                      style: AppTextStyle.headline3.copyWith(fontSize: 22),
                    ),
                  ),
                  Spacer(),
                  if (owner) _buildCreateCommunityButton(),
                ],
              );
            },
          ),
        ),
      );

  Widget _buildCreateCommunityButton() {
    return GestureDetector(
      onTap: _createCommunityPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          JuntoInkWell(
            onTap: _createCommunityPressed,
            boxShape: BoxShape.circle,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white,
              ),
              child: DottedBorder(
                dashPattern: const [3, 3],
                borderType: BorderType.Circle,
                child: Icon(Icons.add),
              ),
            ),
          ),
          if (!responsiveLayoutService.isMobile(context)) ...[
            SizedBox(width: 10),
            JuntoText(
              'Start a community',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCommunitiesCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsiveLayoutService.isMobile(context) ? 20 : 0),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SizedBox(
          height: 295,
          child: JuntoStreamBuilder<List<Junto>>(
            entryFrom: 'Homepage._buildCommunitiesCarousel',
            stream: juntoUserDataService.userCommunities,
            builder: (context, juntosUserBelongsTo) {
              if (juntosUserBelongsTo == null) return CircularProgressIndicator();
              return juntosUserBelongsTo.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Text(
                            "You haven't joined any communities.",
                            style: AppTextStyle.body,
                          ),
                        ])
                  : ListView.builder(
                      dragStartBehavior: DragStartBehavior.down,
                      physics: ClampingScrollPhysics(),
                      itemExtent: 315,
                      shrinkWrap: responsiveLayoutService.isMobile(context),
                      scrollDirection: Axis.horizontal,
                      itemCount: juntosUserBelongsTo.length,
                      itemBuilder: (BuildContext context, int index) {
                        final junto = juntosUserBelongsTo[index];

                        return _buildCommunityCard(junto);
                      },
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(Junto junto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        JuntoInkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => routerDelegate.beamTo(JuntoPageRoutes(
            juntoDisplayId: junto.displayId,
          ).juntoHome),
          child: SizedBox(
            height: _communityCardSize,
            width: _communityCardSize,
            child: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (junto.bannerImageUrl == null || junto.bannerImageUrl!.trim().isEmpty) ...[
                    Container(
                        color: ThemeUtils.parseColor(junto.themeDarkColor) ?? AppColor.darkBlue),
                  ] else ...[
                    JuntoImage(
                      junto.bannerImageUrl,
                      width: _communityCardSize,
                      height: _communityCardSize,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      // Black54 on a white background with white text (worst case scenario)
                      // has a contrast ratio of 4.54, which is the minimum value of 4.5
                      color: Colors.black54,
                    ),
                  ],
                  _buildCommunityCardOverlay(junto),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _buildCommunityCardOverlay(Junto junto) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JuntoCircleIcon(junto),
            SizedBox(height: 10),
            JuntoText(
              (junto.name ?? 'Unnamed Community').toUpperCase(),
              style: AppTextStyle.eyebrow.copyWith(color: AppColor.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 78,
              width: 255,
              child: JuntoText(
                junto.tagLine ?? junto.description ?? '',
                style: AppTextStyle.headline3.copyWith(color: AppColor.white),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ),
          ],
        ),
      );
}

/// This is a modified version of [ClampingScrollPhysics] which accepts a negative offset which will
/// be applied to the calculations for where to clamp the scroll position
class _AllowNegativeScrollPhysics extends ScrollPhysics {
  final double allowedNegativeOffset;

  const _AllowNegativeScrollPhysics(
    this.allowedNegativeOffset, {
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  _AllowNegativeScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _AllowNegativeScrollPhysics(allowedNegativeOffset, parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>('The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>('The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <= (position.minScrollExtent - allowedNegativeOffset)) // underscroll
    {
      return value - position.pixels;
    }
    if ((position.maxScrollExtent + allowedNegativeOffset) <= position.pixels &&
        position.pixels < value) // overscroll
    {
      return value - position.pixels;
    }
    if (value < (position.minScrollExtent - allowedNegativeOffset) &&
        (position.minScrollExtent - allowedNegativeOffset) < position.pixels) // hit top edge
    {
      return value - (position.minScrollExtent - allowedNegativeOffset);
    }
    if (position.pixels < (position.maxScrollExtent + allowedNegativeOffset) &&
        (position.maxScrollExtent + allowedNegativeOffset) < value) // hit bottom edge
    {
      return value - (position.maxScrollExtent + allowedNegativeOffset);
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    final pastEnd = position.pixels > position.maxScrollExtent + allowedNegativeOffset;
    final pastStart = position.pixels < position.minScrollExtent - allowedNegativeOffset;
    if (pastEnd || pastStart) {
      double? end;
      if (pastEnd) end = position.maxScrollExtent;
      if (pastStart) end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent - allowedNegativeOffset) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent + allowedNegativeOffset) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
