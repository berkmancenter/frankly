import 'dart:math';

import 'package:client/core/widgets/buttons/circle_icon_button.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/dialog_flow.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/community/presentation/widgets/community_icon_or_logo.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/user/public_user_info.dart';

import '../../../community/utils/community_theme_utils.dart.dart';

/// This is the top section of the home page that displays a carousel of images which link to the community home pages
class MyCommunitiesSection extends StatefulWidget {
  const MyCommunitiesSection({Key? key}) : super(key: key);

  @override
  _MyCommunitiesSectionState createState() => _MyCommunitiesSectionState();
}

class _MyCommunitiesSectionState extends State<MyCommunitiesSection> {
  static const double _communityCardSize = 295;

  void _createCommunityPressed() {
    guardSignedIn(() => DialogFlow().show());
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
        padding: EdgeInsets.symmetric(
          horizontal: responsiveLayoutService.isMobile(context) ? 20 : 0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsiveLayoutService.isMobile(context) ? 550 : 1100,
          ),
          child: UserInfoBuilder(
            userId: userService.currentUserId,
            builder: (
              BuildContext context,
              bool isLoading,
              AsyncSnapshot<PublicUserInfo?> snapshot,
            ) {
              final userInfo = snapshot.data;
              if (isLoading) {
                return Row(children: const [CircularProgressIndicator()]);
              }
              final owner = userInfo?.isOwner ?? false;
              return Row(
                children: [
                  HeightConstrainedText(
                    'My Communities',
                    style: AppTextStyle.headline3.copyWith(fontSize: 22),
                  ),
                  Spacer(),
                  if (owner || Uri.base.origin.contains('localhost'))
                    _buildCreateCommunityButton(),
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
          Semantics(
            label: 'Start a community',
            button: true,
            child: CircleIconButton(
              onPressed: _createCommunityPressed,
              icon: Icons.add,
              toolTipText: 'Start a community',
            ),
          ),
          if (!responsiveLayoutService.isMobile(context)) ...[
            SizedBox(width: 10),
            HeightConstrainedText(
              'Start a community',
              style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunitiesCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveLayoutService.isMobile(context) ? 20 : 0,
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SizedBox(
          height: 295,
          child: CustomStreamBuilder<List<Community>>(
            entryFrom: 'Homepage._buildCommunitiesCarousel',
            stream: userDataService.userCommunities,
            builder: (context, communitiesUserBelongsTo) {
              if (communitiesUserBelongsTo == null) {
                return CircularProgressIndicator();
              }
              return communitiesUserBelongsTo.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "You haven't joined any communities.",
                          style: AppTextStyle.body,
                          textAlign: responsiveLayoutService.isMobile(context)
                              ? TextAlign.center
                              : null,
                        ),
                      ],
                    )
                  : ListView.builder(
                      dragStartBehavior: DragStartBehavior.down,
                      physics: ClampingScrollPhysics(),
                      itemExtent: 315,
                      shrinkWrap: responsiveLayoutService.isMobile(context),
                      scrollDirection: Axis.horizontal,
                      itemCount: communitiesUserBelongsTo.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = communitiesUserBelongsTo[index];

                        return _buildCommunityCard(community);
                      },
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(Community community) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomInkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => routerDelegate.beamTo(
            CommunityPageRoutes(
              communityDisplayId: community.displayId,
            ).communityHome,
          ),
          child: SizedBox(
            height: _communityCardSize,
            width: _communityCardSize,
            child: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (community.bannerImageUrl == null ||
                      community.bannerImageUrl!.trim().isEmpty) ...[
                    Container(
                      color: ThemeUtils.parseColor(community.themeDarkColor) ??
                          context.theme.colorScheme.primary,
                    ),
                  ] else ...[
                    ProxiedImage(
                      community.bannerImageUrl,
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
                  _buildCommunityCardOverlay(community),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _buildCommunityCardOverlay(Community community) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommunityCircleIcon(community),
            SizedBox(height: 10),
            HeightConstrainedText(
              (community.name ?? 'Unnamed Community').toUpperCase(),
              style: AppTextStyle.eyebrow
                  .copyWith(color: context.theme.colorScheme.onPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 78,
              width: 255,
              child: HeightConstrainedText(
                community.tagLine ?? community.description ?? '',
                style: AppTextStyle.headline3
                    .copyWith(color: context.theme.colorScheme.onPrimary),
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
    return _AllowNegativeScrollPhysics(
      allowedNegativeOffset,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            '$runtimeType.applyBoundaryConditions() was called redundantly.',
          ),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>(
            'The physics object in question was',
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
          DiagnosticsProperty<ScrollMetrics>(
            'The position object in question was',
            position,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <=
            (position.minScrollExtent - allowedNegativeOffset)) // underscroll
    {
      return value - position.pixels;
    }
    if ((position.maxScrollExtent + allowedNegativeOffset) <= position.pixels &&
        position.pixels < value) // overscroll
    {
      return value - position.pixels;
    }
    if (value < (position.minScrollExtent - allowedNegativeOffset) &&
        (position.minScrollExtent - allowedNegativeOffset) <
            position.pixels) // hit top edge
    {
      return value - (position.minScrollExtent - allowedNegativeOffset);
    }
    if (position.pixels < (position.maxScrollExtent + allowedNegativeOffset) &&
        (position.maxScrollExtent + allowedNegativeOffset) <
            value) // hit bottom edge
    {
      return value - (position.maxScrollExtent + allowedNegativeOffset);
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = this.tolerance;
    final pastEnd =
        position.pixels > position.maxScrollExtent + allowedNegativeOffset;
    final pastStart =
        position.pixels < position.minScrollExtent - allowedNegativeOffset;
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
    if (velocity > 0.0 &&
        position.pixels >= position.maxScrollExtent - allowedNegativeOffset) {
      return null;
    }
    if (velocity < 0.0 &&
        position.pixels <= position.minScrollExtent + allowedNegativeOffset) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
