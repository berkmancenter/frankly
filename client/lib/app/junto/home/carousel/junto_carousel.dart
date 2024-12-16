import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/home/carousel/carousel_controls.dart';
import 'package:junto/app/junto/home/carousel/carousel_tabs.dart';
import 'package:junto/app/junto/home/carousel/drag_animator.dart';
import 'package:junto/app/junto/home/carousel/image_carousel.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

/// Receives junto and corresponding discussions and topics pre-loaded from the carousel_initializer,
/// arranges the components of the carousel in a stack, and keeps track of the animation controllers
/// and current state.
class JuntoCarousel extends StatefulWidget {
  final Junto junto;
  final List<Topic> featuredTopics;
  final List<Discussion> featuredDiscussions;
  final List<String> featuredDiscussionImages;

  const JuntoCarousel({
    required this.junto,
    this.featuredTopics = const [],
    this.featuredDiscussions = const [],
    this.featuredDiscussionImages = const [],
    Key? key,
  }) : super(key: key);

  @override
  _JuntoCarouselState createState() => _JuntoCarouselState();
}

class _JuntoCarouselState extends State<JuntoCarousel> with TickerProviderStateMixin {
  static const kCarouselPadding = 24.0;
  static const kItemPadding = 4.0;
  static const kTransitionDuration = Duration(milliseconds: 450);
  static const kCarouselDuration = Duration(seconds: 4);

  late final AnimationController _indicatorAnimationController;
  late final AnimationController _imageAnimationController;

  int _selectedIndex = 0;
  double _pauseValue = 0;

  int get _length => (widget.featuredTopics).length + (widget.featuredDiscussions).length + 1;

  double get _carouselSize => responsiveLayoutService.isMobile(context)
      ? min(MediaQuery.of(context).size.width, AppSize.kMaxCarouselSize)
      : min(AppSize.kMaxCarouselSize, (MediaQuery.of(context).size.width - 100) / 2);

  int get _nextIndex => (_selectedIndex + 1) % _length;

  int get _previousIndex => (_selectedIndex - 1) % _length;

  double get _indicatorWidth =>
      ((_carouselSize - 2 * kCarouselPadding) / _length) - (2 * kItemPadding);

  double get _animatedProgressBarWidth =>
      (_indicatorAnimationController.isAnimating || _indicatorAnimationController.value == 1)
          ? _indicatorAnimationController.value
          : _pauseValue;

  String _generateRandomBannerImage(Junto junto) {
    return generateRandomImageUrl(seed: junto.id.hashCode);
  }

  Discussion? get _selectedDiscussion {
    final _index = _selectedIndex - 1;
    if (_index >= 0 && _index < widget.featuredDiscussions.length) {
      return widget.featuredDiscussions[_index];
    } else {
      return null;
    }
  }

  Topic? get _selectedTopic {
    final _index = _selectedIndex - widget.featuredDiscussions.length - 1;
    if (_index >= 0 && _index < widget.featuredTopics.length) {
      return widget.featuredTopics[_index];
    } else {
      return null;
    }
  }

  List<String?> get _bannerImageUrls {
    String? bannerImageUrl = widget.junto.bannerImageUrl;

    return <String?>[
      if (_length == 1)
        bannerImageUrl
      else if (_length == 2) ...[
        bannerImageUrl,
        if (widget.featuredDiscussionImages.isNotEmpty) widget.featuredDiscussionImages.first,
        if (widget.featuredTopics.isNotEmpty)
          widget.featuredTopics.first.image ??
              generateRandomImageUrl(seed: widget.featuredTopics.first.id.hashCode),
      ] else
        ...List.generate(min(_length, 5), (i) {
          final List<String?> items = [
            bannerImageUrl,
            ...widget.featuredDiscussionImages,
            ...widget.featuredTopics
                .map((e) => e.image ?? generateRandomImageUrl(seed: e.id.hashCode)),
          ];
          final j = (_selectedIndex + i - 2) % items.length;
          return items[j];
        })
    ];
  }

  bool get _isFirstOfTwoSelected => _length == 2 && _selectedIndex == 0;

  bool get _isSecondOfTwoSelected => _length == 2 && _selectedIndex == 1;

  @override
  void initState() {
    _indicatorAnimationController = AnimationController(
      duration: kCarouselDuration,
      vsync: this,
    );
    _imageAnimationController = AnimationController(
      duration: kTransitionDuration,
      lowerBound: -1.0,
      value: 0.0,
      vsync: this,
    );

    play();

    super.initState();
  }

  @override
  void dispose() {
    _indicatorAnimationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  double _carouselTabTextContentWidth(int index) => index > 0 ? _carouselSize : double.infinity;

  void animateToNextItem() async {
    if (_isSecondOfTwoSelected) {
      await _slideToPreviousCarouselTab();
    } else {
      await _slideToNextCarouselTab();
    }
    increment();
  }

  void animateToPreviousItem() async {
    if (_isFirstOfTwoSelected) {
      await _slideToNextCarouselTab();
    } else {
      await _slideToPreviousCarouselTab();
    }
    decrement();
  }

  void increment() {
    if (mounted) {
      setState(() {
        _selectedIndex = _nextIndex;
        _indicatorAnimationController.value = 0;
        animateCarousel();
      });
    }
  }

  void decrement() {
    if (mounted) {
      setState(() {
        _selectedIndex = _previousIndex;
        _indicatorAnimationController.value = 0;
        animateCarousel();
      });
    }
  }

  void pause() {
    if (mounted) {
      setState(() {
        _pauseValue = _indicatorAnimationController.value;
        _indicatorAnimationController.stop();
      });
    }
  }

  void play() {
    if (mounted) {
      setState(() {
        animateCarousel(_pauseValue);
        _pauseValue = 0;
      });
    }
  }

  void animateCarousel([double? fromValue]) {
    _indicatorAnimationController.forward(from: fromValue);
  }

  Future<void> _slideToNextCarouselTab() async {
    unawaited(_imageAnimationController.animateTo(1, curve: Curves.easeOut));
    unawaited(_indicatorAnimationController.animateTo(.99, duration: kTransitionDuration));
    _pauseValue = .99;
    await Future.delayed(kTransitionDuration);
    if (mounted) {
      _imageAnimationController.value = 0;
    }
  }

  Future<void> _slideToPreviousCarouselTab() async {
    unawaited(_imageAnimationController.animateTo(-1, curve: Curves.easeOut));
    unawaited(_indicatorAnimationController.animateTo(0, duration: kTransitionDuration));
    _pauseValue = 0.0;
    await Future.delayed(kTransitionDuration);
    if (mounted) {
      _imageAnimationController.value = 0;
    }
  }

  void _checkIfCarouselFull() {
    if (_indicatorAnimationController.value == 1 && !_imageAnimationController.isAnimating) {
      animateToNextItem();
    }
  }

  void _tappedCarousel(TapUpDetails details) {
    if (_selectedIndex == 0) {
      return;
    } else if (_selectedIndex <= widget.featuredDiscussions.length) {
      return routerDelegate.beamTo(
        JuntoPageRoutes(
          juntoDisplayId: widget.junto.displayId,
        ).discussionPage(
          topicId: _selectedDiscussion!.topicId,
          discussionId: _selectedDiscussion!.id,
        ),
      );
    } else {
      return routerDelegate.beamTo(
        JuntoPageRoutes(
          juntoDisplayId: widget.junto.displayId,
        ).topicPage(
          topicId: _selectedTopic!.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: min(MediaQuery.of(context).size.width, 1400),
        height: _carouselSize,
        child: Stack(
          children: [
            DragAnimator(
              animationController: _imageAnimationController,
              onDragStart: pause,
              onDragEnd: play,
              gestureDetectorHeight: _carouselSize,
              animationControllerValueDivisor: _carouselSize,
              dragAllowed: () => !_imageAnimationController.isAnimating,
              triggerDragForwardAction: increment,
              triggerDragBackAction: decrement,
              dragActionThreshold: _carouselSize,
              dragBackLocked: () => _isFirstOfTwoSelected,
              dragForwardLocked: () => _isSecondOfTwoSelected,
              isActive: _length > 1,
              onBackgroundTap: _tappedCarousel,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageCarousel(
                      reverseAnimation: _isSecondOfTwoSelected,
                      imageAnimationController: _imageAnimationController,
                      orderedImageUrls: _bannerImageUrls,
                      imageToDarkenFully: widget.junto.bannerImageUrl ?? '',
                    ),
                    _buildTextContent(),
                  ],
                ),
              ),
            ),
            if (_length > 1) _buildCarouselIndicatorAndControls(),
          ],
        ),
      ),
    );
  }

  Widget _carouselTabItem(int index) {
    if (index == 0) {
      return AboutJuntoCarouselTab(
        junto: widget.junto,
      );
    } else if (index < widget.featuredDiscussions.length + 1) {
      return FeaturedDiscussionCarouselTab(
        discussion: widget.featuredDiscussions[index - 1],
      );
    } else {
      return FeaturedTopicCarouselTab(
        topic: widget.featuredTopics[index - widget.featuredDiscussions.length - 1],
      );
    }
  }

  Widget _buildTextContent() => AnimatedBuilder(
        animation: _imageAnimationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Current item text
              _CarouselTabWrapper(
                opacity: 1 - _imageAnimationController.value.abs(),
                maxWidth: _carouselTabTextContentWidth(_selectedIndex),
                child: _carouselTabItem(_selectedIndex),
              ),
              // Next item text
              if (!_isSecondOfTwoSelected && _length != 1)
                _CarouselTabWrapper(
                  opacity: _imageAnimationController.value.clamp(0.0, 1.0),
                  maxWidth: _carouselTabTextContentWidth(_nextIndex),
                  child: _carouselTabItem(_nextIndex),
                ),
              // Previous item text
              if (!_isFirstOfTwoSelected && _length != 1)
                _CarouselTabWrapper(
                  opacity: _imageAnimationController.value.clamp(-1.0, 0.0).abs(),
                  child: _carouselTabItem(_previousIndex),
                  maxWidth: _carouselTabTextContentWidth(_previousIndex),
                ),
            ],
          );
        },
      );

  Widget _buildCarouselIndicatorAndControls() => Center(
        child: SizedBox(
          width: _carouselSize,
          child: Padding(
            padding: const EdgeInsets.all(kCarouselPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    JuntoCarouselControls(
                      controller: _indicatorAnimationController,
                      onPause: pause,
                      onPlay: play,
                      onNext: animateToNextItem,
                      onPrevious: animateToPreviousItem,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _indicatorAnimationController,
                  builder: (context, child) {
                    _checkIfCarouselFull();

                    return _buildAnimatedIndicatorRow;
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget get _buildAnimatedIndicatorRow => Row(
        children: [
          ...List.generate(_selectedIndex, (i) => _buildFullIndicator),
          _buildProgressIndicator(_animatedProgressBarWidth, _indicatorWidth),
          ...List.generate(_length - _selectedIndex - 1, (i) => _buildEmptyIndicator),
        ],
      );

  Widget get _buildFullIndicator => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kItemPadding),
          child: Container(
            height: 5,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
          ),
        ),
      );

  Widget get _buildEmptyIndicator => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kItemPadding),
          child: Container(
            height: 5,
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(3)),
          ),
        ),
      );

  Widget _buildProgressIndicator(double pctProgress, double width) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kItemPadding),
          child: Stack(
            children: [
              Container(
                height: 5,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 5,
                width: width * pctProgress,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CarouselTabWrapper extends StatelessWidget {
  final double maxWidth;
  final double opacity;
  final Widget child;

  const _CarouselTabWrapper({
    required this.maxWidth,
    required this.opacity,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(_JuntoCarouselState.kCarouselPadding),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        ),
      ),
    );
  }
}
